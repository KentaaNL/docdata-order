# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Docdata::Order do
  describe '.config' do
    it 'has no default logger' do
      expect(described_class.config.logger).to be_nil
    end

    it 'has default open_timeout and read_timeout' do
      expect(described_class.config.open_timeout).to eq(30)
      expect(described_class.config.read_timeout).to eq(30)
    end
  end

  describe '.configure' do
    it 'yields the config object' do
      yielded = nil
      described_class.configure do |c|
        yielded = c
      end
      expect(yielded).to eq(described_class.config)
    end

    it 'allows changing configuration values' do
      logger = Logger.new($stdout)

      described_class.configure do |c|
        c.logger = logger
        c.open_timeout = 60
        c.read_timeout = 120
      end

      expect(described_class.config.logger).to eq(logger)
      expect(described_class.config.open_timeout).to eq(60)
      expect(described_class.config.read_timeout).to eq(120)
    end

    it 'does not allow replacing the config object' do
      expect { described_class.config = Docdata::Order::Configuration.new }.to raise_error(NoMethodError)
    end
  end

  describe '.reset!' do
    let(:logger) { Logger.new($stdout) }

    before do
      described_class.configure do |c|
        c.logger = logger
        c.open_timeout = 60
        c.read_timeout = 120
      end
    end

    it 'resets configuration to default values' do
      described_class.reset!

      expect(described_class.config.logger).to be_nil
      expect(described_class.config.open_timeout).to eq(30)
      expect(described_class.config.read_timeout).to eq(30)
    end

    it 'provides a fresh config object' do
      old_config = described_class.config
      described_class.reset!
      expect(described_class.config).not_to eq(old_config)
    end
  end
end
