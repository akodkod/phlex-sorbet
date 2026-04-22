# typed: true
# frozen_string_literal: true

module Phlex
  module Sorbet
    # Base error class for all Phlex::Sorbet errors
    class Error < StandardError; end

    # Raised when a component doesn't define a Props class or it's not a T::Struct
    class PropsNotDefinedError < Error; end

    # Raised when prop validation fails at instantiation time
    class InvalidPropsError < Error; end

    # Raised when sorbet-schema deserialization fails
    class SerializationError < Error; end
  end
end
