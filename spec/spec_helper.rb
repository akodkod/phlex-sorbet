# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "phlex"
require "phlex/sorbet"
require "phlex/sorbet/rspec"

# Load all test components
Dir[File.join(__dir__, "support/components/**/*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
