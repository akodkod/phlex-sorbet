# typed: false
# frozen_string_literal: true

require "sorbet-runtime"

module Phlex
  module Sorbet
    # Class methods added to components that include Phlex::Sorbet
    module ClassMethods
      extend T::Sig

      # Returns the Props class for this component, or nil if not defined.
      #
      # @return [Class, nil] The Props T::Struct class or nil
      sig { returns(T.nilable(T.class_of(T::Struct))) }
      def props_class
        return @props_class if defined?(@props_class)

        @props_class = T.let(
          begin
            klass = const_defined?(:Props) ? const_get(:Props) : nil
            validate_props_class!(klass) if klass
            klass
          end,
          T.nilable(T.class_of(T::Struct)),
        )
      end

      # Builds and validates a Props instance from incoming kwargs.
      # Uses sorbet-schema's HashSerializer so that nested T::Structs and
      # coercible primitive types (e.g. "1" -> 1) are supported.
      #
      # Returns nil if no Props class is defined and no kwargs were given.
      #
      # @param kwargs [Hash] Arguments matching the Props T::Struct
      # @return [T::Struct, nil] Validated Props instance or nil
      # @raise [InvalidPropsError] if validation fails
      # @raise [PropsNotDefinedError] if kwargs are given but no Props class is defined
      sig { params(kwargs: T.untyped).returns(T.nilable(T::Struct)) }
      def build_props(**kwargs)
        klass = props_class
        unless klass
          return nil if kwargs.empty?

          raise PropsNotDefinedError,
                "#{name} received props (#{kwargs.keys.inspect}) but does not define a Props class"
        end

        deserialize_props(klass, kwargs)
      rescue InvalidPropsError, PropsNotDefinedError
        raise
      rescue StandardError => e
        raise InvalidPropsError, "Invalid props for #{name}: #{e.message}"
      end

      private

      # Runs sorbet-schema deserialization for the given Props class and kwargs.
      sig { params(klass: T.class_of(T::Struct), kwargs: T::Hash[T.any(String, Symbol), T.untyped]).returns(T::Struct) }
      def deserialize_props(klass, kwargs)
        serializer = Typed::HashSerializer.new(schema: klass.schema)
        result = serializer.deserialize(kwargs.transform_keys(&:to_s))
        return result.payload if result.success?

        raise InvalidPropsError, "Invalid props for #{name}: #{result.error.message}"
      end

      # Validates that the Props class is a T::Struct
      #
      # @param klass [Class] The class to validate
      # @return [Class] The validated class
      # @raise [PropsNotDefinedError] if invalid
      sig { params(klass: T.untyped).returns(T.class_of(T::Struct)) }
      def validate_props_class!(klass)
        unless klass.is_a?(Class) && klass < T::Struct
          raise PropsNotDefinedError,
                "#{name}::Props must inherit from T::Struct, got #{klass.class}"
        end

        klass
      end
    end
  end
end
