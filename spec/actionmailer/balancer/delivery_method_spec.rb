# frozen_string_literal: true

RSpec.describe ActionMailer::Balancer::DeliveryMethod do # rubocop:disable RSpec/SpecFilePathFormat
  describe '#deliver!' do
    subject(:deliver!) { described_class.new(settings).deliver!(message) }

    let(:settings) do
      {
        delivery_methods: [
          {
            method: :smtp,
            settings: {
              method_num: 1
            },
            weight: 90
          },
          {
            method: :sendmail,
            settings: {
              method_num: 2
            },
            weight: 8
          },
          {
            method: :sendmail,
            weight: 2
          }
        ]
      }
    end
    let(:message) { Mail::Message.new }
    let(:smtp) { instance_double(Mail::SMTP, deliver!: true) }
    let(:sendmail) { instance_double(Mail::Sendmail, deliver!: true) }
    let(:sendmail_defaults) { instance_double(Mail::Sendmail, deliver!: true) }

    def stub_random(value)
      allow_any_instance_of(described_class).to receive(:rand).with(no_args).and_return(value) # rubocop:disable RSpec/AnyInstance
    end

    before do
      allow(Mail::SMTP).to receive(:new).and_call_original
      allow(Mail::SMTP).to receive(:new).with({ method_num: 1 }).and_return(smtp)
      allow(Mail::Sendmail).to receive(:new).with({ method_num: 2 }).and_return(sendmail)
      allow(Mail::Sendmail).to receive(:new).with({}).and_return(sendmail_defaults)
      stub_random(0.5)
    end

    context 'when settings are not set' do
      let(:settings) { {} }

      it 'raises an error' do
        expect { deliver! }.to raise_error(ActionMailer::Balancer::SettingsError, 'No settings set')
      end
    end

    context 'when delivery methods are not set' do
      let(:settings) { { some_setting: true } }

      it 'raises an error' do
        expect { deliver! }.to raise_error(ActionMailer::Balancer::SettingsError, 'No delivery methods set')
      end
    end

    context 'when first method is chosen' do
      it 'delivers through it' do
        deliver!

        expect(smtp).to have_received(:deliver!).with(message).once
        expect(sendmail).not_to have_received(:deliver!)
        expect(sendmail_defaults).not_to have_received(:deliver!)
        expect(message.delivery_method).to eq(smtp)
      end
    end

    context 'when second method is chosen' do
      before { stub_random(0.95) }

      it 'delivers through it' do
        deliver!

        expect(sendmail).to have_received(:deliver!).with(message).once
        expect(smtp).not_to have_received(:deliver!)
        expect(sendmail_defaults).not_to have_received(:deliver!)
      end
    end

    context 'when third method is chosen' do
      before { stub_random(0.99) }

      it 'delivers through it with empty settings' do
        deliver!

        expect(sendmail_defaults).to have_received(:deliver!).with(message).once
        expect(smtp).not_to have_received(:deliver!)
        expect(sendmail).not_to have_received(:deliver!)
      end
    end

    context 'when the method name is a string' do
      let(:settings) { { delivery_methods: [{ method: 'smtp', settings: { method_num: 1 }, weight: 1 }] } }

      it 'delivers through it' do
        deliver!

        expect(smtp).to have_received(:deliver!).with(message).once
      end
    end

    context 'when weights are floats' do
      let(:settings) do
        {
          delivery_methods: [
            { method: :smtp, settings: { method_num: 1 }, weight: 0.25 },
            { method: :sendmail, settings: { method_num: 2 }, weight: 0.75 }
          ]
        }
      end

      before { stub_random(0.3) }

      it 'picks by share of the total' do
        deliver!

        expect(sendmail).to have_received(:deliver!).once
      end
    end

    context 'when a method has weight 0' do
      let(:settings) do
        {
          delivery_methods: [
            { method: :smtp, settings: { method_num: 1 }, weight: 0 },
            { method: :sendmail, settings: { method_num: 2 }, weight: 1 }
          ]
        }
      end

      before { stub_random(0.0) }

      it 'never chooses it' do
        deliver!

        expect(smtp).not_to have_received(:deliver!)
        expect(sendmail).to have_received(:deliver!).once
      end
    end

    context 'when weight is not set' do
      let(:settings) do
        {
          delivery_methods: [
            {
              method: :smtp,
              settings: {
                method_num: 1
              }
            },
            {
              method: :sendmail,
              settings: {
                method_num: 2
              },
              weight: 10
            }
          ]
        }
      end

      it 'raises an error' do
        expect { deliver! }.to raise_error(
          ActionMailer::Balancer::SettingsError, 'No weight set for delivery method smtp'
        )
      end
    end

    context 'when weight is negative' do
      let(:settings) { { delivery_methods: [{ method: :smtp, weight: -1 }] } }

      it 'raises an error' do
        expect { deliver! }.to raise_error(
          ActionMailer::Balancer::SettingsError, 'Weight for delivery method smtp must be a non-negative number, got -1'
        )
      end
    end

    context 'when all weights are 0' do
      let(:settings) { { delivery_methods: [{ method: :smtp, weight: 0 }, { method: :sendmail, weight: 0 }] } }

      it 'raises an error' do
        expect { deliver! }.to raise_error(
          ActionMailer::Balancer::SettingsError, 'At least one delivery method must have a weight above 0'
        )
      end
    end

    context 'when the delivery method is unknown' do
      let(:settings) { { delivery_methods: [{ method: :smpt, weight: 1 }] } }

      it 'raises an error' do
        expect { deliver! }.to raise_error(ActionMailer::Balancer::SettingsError, /Unknown delivery method :smpt/)
      end
    end

    context 'when the method name is missing' do
      let(:settings) { { delivery_methods: [{ weight: 1 }] } }

      it 'raises an error' do
        expect { deliver! }.to raise_error(ActionMailer::Balancer::SettingsError, 'No method set for delivery method')
      end
    end

    context 'when a delivery method is the balancer itself' do
      let(:settings) { { delivery_methods: [{ method: :balancer, weight: 1 }] } }

      before { ActionMailer::Base.add_delivery_method(:balancer, described_class) }

      it 'raises an error' do
        expect { deliver! }.to raise_error(
          ActionMailer::Balancer::SettingsError, "Delivery method balancer can't be a balancer itself"
        )
      end
    end
  end

  describe 'delivering through ActionMailer' do
    let(:mailer) do
      Class.new(ActionMailer::Base) do
        def self.name = 'BalancedMailer'

        def hello
          mail(from: 'app@example.com', to: 'user@example.com', subject: 'Hello', body: 'Hi')
        end
      end
    end
    let(:interceptor) do
      Class.new do
        def self.calls = @calls ||= 0

        def self.delivering_email(message)
          @calls = calls + 1
          message.subject = "[STAGING] #{message.subject}"
        end
      end
    end
    let(:observer) do
      Class.new do
        def self.seen = @seen ||= []

        def self.delivered_email(message)
          seen << message.delivery_method.class
        end
      end
    end

    before do
      ActionMailer::Base.add_delivery_method(:balancer, described_class)
      ActionMailer::Base.deliveries.clear
      mailer.delivery_method = :balancer
      mailer.balancer_settings = { delivery_methods: [{ method: :test, weight: 1 }] }
      ActionMailer::Base.register_interceptor(interceptor)
      ActionMailer::Base.register_observer(observer)
    end

    after do
      ActionMailer::Base.unregister_interceptor(interceptor)
      ActionMailer::Base.unregister_observer(observer)
    end

    it 'delivers the message once' do
      mailer.hello.deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'runs interceptors once' do
      mailer.hello.deliver_now

      expect(interceptor.calls).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq('[STAGING] Hello')
    end

    it 'runs observers once and shows them the chosen delivery method' do
      mailer.hello.deliver_now

      expect(observer.seen).to eq([Mail::TestMailer])
    end
  end
end
