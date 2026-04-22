# typed: false
# frozen_string_literal: true

require_relative "rspec/matchers"

# Auto-include matchers in RSpec if available
if defined?(RSpec)
  RSpec.configure do |config|
    config.include Phlex::Sorbet::RSpec::Matchers
  end
end
