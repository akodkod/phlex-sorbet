# typed: false
# frozen_string_literal: true

require "sorbet-runtime"

module Phlex
  module Sorbet
    # Instance methods prepended into components that include Phlex::Sorbet.
    # Wraps `initialize` to build a typed Props struct from incoming kwargs
    # and exposes each prop as a method on the component instance.
    module InstanceMethods
      extend T::Sig

      # Builds typed props, defines per-prop accessor methods, then calls
      # super so the Phlex base class can initialize as usual.
      #
      # @param kwargs [Hash] Arguments matching the Props T::Struct
      # @raise [InvalidPropsError] if validation fails
      def initialize(**kwargs, &)
        @props = self.class.build_props(**kwargs)
        define_prop_accessors if @props
        super(&)
      end

      # Accessor for typed props.
      #
      # @return [T::Struct, nil] The Props instance or nil
      sig { returns(T.nilable(T::Struct)) }
      def props
        @props
      end

      private

      # Define getter methods for each field in the Props struct.
      # Allows direct access like `user_id` instead of `props.user_id`.
      #
      # @return [void]
      sig { void }
      def define_prop_accessors
        return unless @props

        @props.class.props.each_key do |field_name|
          # Skip if a method with the same name is already defined on the
          # component (avoid clobbering user-defined methods or Phlex internals).
          next if respond_to?(field_name, true) && !@props.respond_to?(field_name)

          define_singleton_method(field_name) do
            @props.public_send(field_name)
          end
        end
      end
    end
  end
end
