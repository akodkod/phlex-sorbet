# typed: false
# frozen_string_literal: true

require "sorbet-runtime"

module Phlex
  module Sorbet
    # Instance methods prepended into components that include Phlex::Sorbet.
    # Wraps `initialize` to build a typed Props struct from incoming kwargs
    # and exposes it via the `props` accessor.
    module InstanceMethods
      extend T::Sig

      # Builds typed props, then calls super so the Phlex base class can
      # initialize as usual.
      #
      # @param kwargs [Hash] Arguments matching the Props T::Struct
      # @raise [InvalidPropsError] if validation fails
      def initialize(**kwargs, &)
        @props = self.class.build_props(**kwargs)
        super(&)
      end

      # Accessor for typed props.
      #
      # @return [T::Struct, nil] The Props instance or nil
      sig { returns(T.nilable(T::Struct)) }
      def props
        @props
      end
    end
  end
end
