# typed: true
# frozen_string_literal: true

require "phlex"
require "sorbet-runtime"
require "sorbet-schema"
require_relative "sorbet/version"
require_relative "sorbet/errors"
require_relative "sorbet/class_methods"
require_relative "sorbet/instance_methods"

# Load Tapioca DSL compilers if Tapioca is available
begin
  require "tapioca/dsl"
  require_relative "../tapioca/dsl/compilers/phlex_sorbet"
  require_relative "../tapioca/dsl/compilers/phlex_kit"
rescue LoadError
  # Tapioca not available, skip compilers
end

module Phlex
  module Sorbet
    extend T::Sig

    # Hook called when Phlex::Sorbet is included in a component class.
    # Wires up class-level Props helpers and prepends an `initialize` that
    # builds a typed `Props` struct from incoming kwargs.
    #
    # @param base [Class] The component class including this module
    sig { params(base: T.untyped).void }
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(InstanceMethods)
    end
  end
end
