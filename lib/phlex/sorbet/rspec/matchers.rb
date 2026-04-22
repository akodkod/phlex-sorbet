# typed: false
# frozen_string_literal: true

module Phlex
  module Sorbet
    module RSpec
      # Custom RSpec matchers for validating Phlex::Sorbet component prop types
      module Matchers
        # Matcher for validating a single prop definition
        #
        # @example
        #   expect(MyComponent).to have_prop(:user_id, Integer)
        #   expect(MyComponent).to have_prop(:notify, T::Boolean).with_default(false)
        class HaveProp
          def initialize(field_name, expected_type = nil)
            @field_name = field_name
            @expected_type = expected_type
            @expected_default = nil
            @check_default = false
          end

          # Chain to check for a specific default value
          def with_default(default_value)
            @expected_default = default_value
            @check_default = true
            self
          end

          def matches?(component_class)
            @actual = component_class
            props = fetch_props(component_class)

            return false unless field_exists?(component_class, props)
            return false unless type_matches?(component_class, props[@field_name])
            return false unless default_matches?(component_class, props[@field_name])

            true
          end

          def failure_message
            @failure_message || "expected #{@actual} to have prop :#{@field_name}"
          end

          def failure_message_when_negated
            "expected #{@actual}::Props not to have prop :#{@field_name}"
          end

          def description
            desc = "have prop :#{@field_name}"
            desc += " of type #{@expected_type}" if @expected_type
            desc += " with default #{@expected_default.inspect}" if @check_default
            desc
          end

          private

          def fetch_props(component_class)
            props_class = component_class.respond_to?(:props_class) ? component_class.props_class : nil
            return {} unless props_class

            props_class.props
          rescue Phlex::Sorbet::PropsNotDefinedError
            {}
          end

          def field_exists?(component_class, props)
            return true if props.key?(@field_name)

            @failure_message = "expected #{component_class}::Props to have prop :#{@field_name}, " \
                               "but it was not defined. " \
                               "Defined props: #{props.keys.map { |k| ":#{k}" }.join(', ')}"
            false
          end

          def type_matches?(component_class, prop_info)
            return true unless @expected_type

            actual_type = prop_info[:type_object]
            return true if types_equal?(actual_type, @expected_type)

            @failure_message = "expected #{component_class}::Props prop :#{@field_name} " \
                               "to be #{@expected_type}, but was #{actual_type}"
            false
          end

          def default_matches?(component_class, prop_info)
            return true unless @check_default

            unless prop_info.key?(:default)
              @failure_message = "expected #{component_class}::Props prop :#{@field_name} " \
                                 "to have a default value, but it was required"
              return false
            end

            actual_default = prop_info[:default]
            actual_default_value = actual_default.is_a?(Proc) ? actual_default.call : actual_default
            return true if actual_default_value == @expected_default

            @failure_message = "expected #{component_class}::Props prop :#{@field_name} " \
                               "to have default value #{@expected_default.inspect}, " \
                               "but was #{actual_default_value.inspect}"
            false
          end

          def types_equal?(actual, expected)
            return true if actual == expected
            return true if actual.to_s == expected.to_s
            return true if actual.respond_to?(:raw_type) && actual.raw_type == expected

            false
          end
        end

        # Matcher for validating multiple props at once
        #
        # @example
        #   expect(MyComponent).to have_props(user_id: Integer, name: String)
        #   expect(MyComponent).to have_props(:user_id, Integer).and_prop(:name, String)
        class HaveProps
          def initialize(args_hash_or_field = nil, expected_type = nil)
            @props_to_check = []

            if args_hash_or_field.is_a?(Hash)
              args_hash_or_field.each do |field_name, type|
                @props_to_check << [field_name, type]
              end
            elsif args_hash_or_field.is_a?(Symbol)
              @props_to_check << [args_hash_or_field, expected_type]
            end
          end

          def and_prop(field_name, expected_type)
            @props_to_check << [field_name, expected_type]
            self
          end

          def matches?(component_class)
            @actual = component_class

            @props_to_check.each do |field_name, expected_type|
              matcher = HaveProp.new(field_name, expected_type)
              unless matcher.matches?(component_class)
                @failure_message = matcher.failure_message
                return false
              end
            end

            true
          end

          def failure_message
            @failure_message || "expected #{@actual} to have the specified props"
          end

          def failure_message_when_negated
            "expected #{@actual}::Props not to have the specified props"
          end

          def description
            desc = @props_to_check.map { |name, type| "#{name}: #{type}" }.join(", ")
            "have props: #{desc}"
          end
        end

        # Matcher for validating that a component accepts specific props
        #
        # @example
        #   expect(MyComponent).to accept_props(user_id: 123)
        class AcceptProps
          def initialize(props)
            @props = props
          end

          def matches?(component_class)
            @actual = component_class

            component_class.build_props(**@props)
            true
          rescue Phlex::Sorbet::InvalidPropsError,
                 Phlex::Sorbet::PropsNotDefinedError,
                 ArgumentError,
                 TypeError => e
            @raised_error = e
            false
          end

          def failure_message
            "expected #{@actual} to accept props #{@props.inspect}, " \
              "but it raised #{@raised_error.class}: #{@raised_error.message}"
          end

          def failure_message_when_negated
            "expected #{@actual} not to accept props #{@props.inspect}, but it did"
          end

          def description
            "accept props #{@props.inspect}"
          end
        end

        # Matcher for validating that a component rejects invalid props
        #
        # @example
        #   expect(MyComponent).to reject_props(user_id: "not an integer")
        #   expect(MyComponent).to reject_props(user_id: "bad").with_error(Phlex::Sorbet::InvalidPropsError)
        class RejectProps
          def initialize(props)
            @props = props
            @expected_error = nil
            @expected_message = nil
          end

          def with_error(error_class, message_pattern = nil)
            @expected_error = error_class
            @expected_message = message_pattern
            self
          end

          def matches?(component_class)
            @actual = component_class

            begin
              component_class.build_props(**@props)
              @accepted = true
              false
            rescue StandardError => e
              @raised_error = e

              return false if @expected_error && !e.is_a?(@expected_error)
              return false if @expected_message && @raised_error.message !~ @expected_message

              true
            end
          end

          def failure_message
            if @accepted
              "expected #{@actual} to reject props #{@props.inspect}, but it accepted them"
            elsif @expected_error && @raised_error && !@raised_error.is_a?(@expected_error)
              "expected #{@actual} to raise #{@expected_error}, but raised #{@raised_error.class}"
            elsif @expected_message && @raised_error
              "expected error message to match #{@expected_message.inspect}, " \
                "but was #{@raised_error.message.inspect}"
            else
              "unexpected state in reject_props matcher"
            end
          end

          def failure_message_when_negated
            "expected #{@actual} not to reject props #{@props.inspect}, " \
              "but it raised #{@raised_error.class}"
          end

          def description
            desc = "reject props #{@props.inspect}"
            desc += " with #{@expected_error}" if @expected_error
            desc += " matching #{@expected_message.inspect}" if @expected_message
            desc
          end
        end

        # DSL methods to create matcher instances

        def have_prop(field_name, expected_type = nil)
          HaveProp.new(field_name, expected_type)
        end

        def have_props(args_hash_or_field = nil, expected_type = nil)
          HaveProps.new(args_hash_or_field, expected_type)
        end

        def accept_props(props)
          AcceptProps.new(props)
        end

        def reject_props(props)
          RejectProps.new(props)
        end
      end
    end
  end
end
