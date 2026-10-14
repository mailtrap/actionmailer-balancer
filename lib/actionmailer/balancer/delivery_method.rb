# frozen_string_literal: true

module ActionMailer
  module Balancer
    class DeliveryMethod
      attr_reader :settings, :delivery_methods, :weights_sum

      def initialize(settings = {})
        @settings = settings
        add_delivery_methods(settings)
      end

      # Switches the message to the chosen delivery method, so observers can see
      # which one was used, and delivers through it directly. Calling
      # message.deliver! instead would run interceptors and observers a second
      # time, since ActionMailer has already run them for this message.
      def deliver!(message)
        delivery_method = choose_delivery_method
        message.delivery_method(delivery_class(delivery_method[:method]), delivery_method[:settings] || {})
        message.delivery_method.deliver!(message)
      end

      private

      def add_delivery_methods(settings)
        validate_settings!(settings)

        @delivery_methods = settings[:delivery_methods]
        @weights_sum = delivery_methods.sum { |method| method[:weight] }
        # Weights near Float::MAX add up to Infinity or, with Array#sum's compensated summation, NaN.
        raise ActionMailer::Balancer::SettingsError, 'The sum of weights is too large' unless weights_sum.finite?
        return if weights_sum.positive?

        raise ActionMailer::Balancer::SettingsError, 'At least one delivery method must have a weight above 0'
      end

      def choose_delivery_method
        target = rand * weights_sum
        delivery_methods.each do |method|
          return method if target < method[:weight]

          target -= method[:weight]
        end
        # Float rounding can leave target just past the last weight.
        delivery_methods.reverse.find { |method| method[:weight].positive? }
      end

      def delivery_class(name)
        ::ActionMailer::Base.delivery_methods.fetch(name.to_sym) do
          raise ActionMailer::Balancer::SettingsError,
                "Unknown delivery method #{name.inspect}, " \
                "known methods: #{::ActionMailer::Base.delivery_methods.keys.map(&:inspect).join(", ")}"
        end
      end

      def validate_settings!(settings)
        raise ActionMailer::Balancer::SettingsError, 'No settings set' if settings.empty?

        unless settings[:delivery_methods].is_a?(Array) && !settings[:delivery_methods].empty?
          raise ActionMailer::Balancer::SettingsError, 'No delivery methods set'
        end

        settings[:delivery_methods].each { |method| validate_delivery_method!(method) }
      end

      def validate_delivery_method!(method)
        name = method[:method]
        unless name.respond_to?(:to_sym)
          raise ActionMailer::Balancer::SettingsError, 'No method set for delivery method'
        end

        if delivery_class(name) <= DeliveryMethod
          raise ActionMailer::Balancer::SettingsError, "Delivery method #{name} can't be a balancer itself"
        end

        validate_weight!(name, method[:weight])
      end

      def validate_weight!(name, weight)
        raise ActionMailer::Balancer::SettingsError, "No weight set for delivery method #{name}" unless weight
        return if weight.is_a?(Numeric) && weight.real? && weight.finite? && !weight.negative?

        raise ActionMailer::Balancer::SettingsError,
              "Weight for delivery method #{name} must be a finite, non-negative number, got #{weight.inspect}"
      end
    end
  end
end
