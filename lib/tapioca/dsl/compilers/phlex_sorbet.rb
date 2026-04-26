# frozen_string_literal: true
# typed: strict

return unless defined?(Tapioca)

module Tapioca
  module Dsl
    module Compilers
      # Generates RBI files for Phlex::Sorbet components.
      #
      # This compiler generates:
      # - A typed `props` accessor returning the component's `Props` struct
      # - A typed `initialize` signature derived from the component's `Props` struct
      class PhlexSorbet < Compiler
        extend T::Sig
        extend T::Generic

        ConstantType = type_member { { fixed: T.class_of(::Phlex::Sorbet) } }

        sig { override.void }
        def decorate
          root.create_path(constant) do |klass|
            generate_props_method(klass) if props_class
            generate_new_method(klass)
            generate_initialize_method(klass)
          end
        end

        sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
        def self.gather_constants
          all_classes.select do |c|
            c.is_a?(Class) && c.included_modules.include?(::Phlex::Sorbet)
          end
        end

        # Builds typed kwarg params from a Props T::Struct class. Returns an
        # empty array when `props_class` is nil. Exposed as a class method so
        # other compilers (e.g. PhlexKit) can reuse the same mapping.
        sig { params(props_class: T.nilable(T.class_of(T::Struct))).returns(T::Array[RBI::TypedParam]) }
        def self.params_for(props_class)
          return [] unless props_class

          props_class.props.map do |field_name, prop_info|
            type = prop_info[:type_object].to_s
            has_default = prop_info.key?(:default)

            param = if has_default
                      RBI::KwOptParam.new(field_name.to_s, "T.unsafe(nil)")
                    else
                      RBI::KwParam.new(field_name.to_s)
                    end

            RBI::TypedParam.new(param: param, type: type)
          end
        end

        private

        sig { returns(T.nilable(T.class_of(T::Struct))) }
        def props_class
          constant.const_get(:Props)
        rescue NameError
          nil
        end

        sig { params(klass: RBI::Scope).void }
        def generate_props_method(klass)
          props = props_class
          return unless props

          klass.create_method(
            "props",
            return_type: T.must(props.name),
          )
        end

        # Phlex::SGML defines an untyped `def self.new(*a, **k, &block)` that
        # shadows `Class#new`, so without an override Sorbet ignores the typed
        # `initialize` above. Emit a typed `self.new` so call sites are checked.
        sig { params(klass: RBI::Scope).void }
        def generate_new_method(klass)
          klass.create_method(
            "new",
            parameters: build_params_signature,
            return_type: "T.attached_class",
            class_method: true,
          )
        end

        sig { params(klass: RBI::Scope).void }
        def generate_initialize_method(klass)
          klass.create_method(
            "initialize",
            parameters: build_params_signature,
            return_type: "void",
          )
        end

        sig { returns(T::Array[RBI::TypedParam]) }
        def build_params_signature
          self.class.params_for(props_class)
        end
      end
    end
  end
end
