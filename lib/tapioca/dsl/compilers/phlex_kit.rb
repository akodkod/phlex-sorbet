# frozen_string_literal: true
# typed: strict

return unless defined?(Tapioca)

module Tapioca
  module Dsl
    module Compilers
      # Generates RBI files for Phlex::Kit modules.
      #
      # When a module `extend Phlex::Kit`, Phlex installs an instance method
      # and a singleton method for every component constant added under that
      # module (see `Phlex::Kit#const_added`). Those methods render the
      # component and are invoked from inside other components like
      # `Card { ... }` or `Button(label: "Save")`.
      #
      # Sorbet only sees `Phlex::Kit#method_missing` and reports such calls as
      # unknown methods. This compiler emits a typed RBI entry for each
      # registered component so call sites type-check.
      class PhlexKit < Compiler
        extend T::Sig
        extend T::Generic

        ConstantType = type_member { { fixed: T::Module[T.anything] } }

        sig { override.void }
        def decorate
          components = component_constants
          return if components.empty?

          generate_kit_methods(components)
          generate_component_includes(components)
        end

        sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
        def self.gather_constants
          all_modules.select do |m|
            !m.is_a?(Class) && m.singleton_class < ::Phlex::Kit
          end
        end

        private

        sig { params(components: T::Hash[Symbol, T::Module[T.anything]]).void }
        def generate_kit_methods(components)
          root.create_path(constant) do |mod|
            components.each do |name, component|
              params = parameters_for(component)
              mod.create_method(
                name.to_s,
                parameters: params,
                return_type: "T.untyped",
              )
              mod.create_method(
                name.to_s,
                parameters: params,
                return_type: "T.untyped",
                class_method: true,
              )
            end
          end
        end

        # Returns typed kwarg parameters when the component includes
        # `Phlex::Sorbet` and defines a `Props` T::Struct (reusing the
        # PhlexSorbet compiler's mapping). Falls back to an untyped
        # `*args, **kwargs, &block` signature otherwise.
        sig { params(component: T::Module[T.anything]).returns(T::Array[RBI::TypedParam]) }
        def parameters_for(component)
          props_class = sorbet_props_class(component)
          return kit_method_parameters unless props_class

          PhlexSorbet.params_for(props_class) + [block_parameter]
        end

        sig { params(component: T::Module[T.anything]).returns(T.nilable(T.class_of(T::Struct))) }
        def sorbet_props_class(component)
          return nil unless component.included_modules.include?(::Phlex::Sorbet)
          return nil unless component.const_defined?(:Props, false)

          klass = component.const_get(:Props, false)
          return nil unless klass.is_a?(Class) && klass < T::Struct

          klass
        rescue StandardError, ::LoadError
          nil
        end

        # At runtime, `Phlex::Kit#const_added` calls `constant.include(me)`
        # on every component class added to the kit. Mirror that in RBI so
        # the kit's instance methods are visible on the component (and on
        # its subclasses, which inherit the include).
        sig { params(components: T::Hash[Symbol, T::Module[T.anything]]).void }
        def generate_component_includes(components)
          kit_name = T.must(constant.name)

          components.each_value do |component|
            root.create_path(component) do |klass|
              klass.create_include(kit_name)
            end
          end
        end

        sig { returns(T::Hash[Symbol, T::Module[T.anything]]) }
        def component_constants
          constant.constants(false).each_with_object({}) do |name, acc|
            next if constant.autoload?(name)

            value = begin
              constant.const_get(name, false)
            rescue StandardError, ::LoadError
              next
            end

            acc[name] = value if value.is_a?(Class) && value < ::Phlex::SGML
          end
        end

        sig { returns(T::Array[RBI::TypedParam]) }
        def kit_method_parameters
          [
            RBI::TypedParam.new(
              param: RBI::RestParam.new("args"),
              type: "T.untyped",
            ),
            RBI::TypedParam.new(
              param: RBI::KwRestParam.new("kwargs"),
              type: "T.untyped",
            ),
            block_parameter,
          ]
        end

        sig { returns(RBI::TypedParam) }
        def block_parameter
          RBI::TypedParam.new(
            param: RBI::BlockParam.new("block"),
            type: "T.nilable(T.proc.void)",
          )
        end
      end
    end
  end
end
