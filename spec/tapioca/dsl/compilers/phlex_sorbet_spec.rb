# frozen_string_literal: true
# typed: false

require "tapioca/internal"
require "tapioca/dsl/pipeline"

RSpec.describe Tapioca::Dsl::Compilers::PhlexSorbet do
  let(:cache_ivars) { [:@all_classes, :@all_modules, :@processable_constants] }
  let(:cache_classes) do
    [
      described_class,
      Tapioca::Dsl::Compilers::PhlexKit,
      Tapioca::Dsl::Compiler,
    ]
  end

  def reset_compiler_caches!
    Tapioca::Dsl::Compiler.requested_constants = []
    cache_classes.each do |cls|
      cache_ivars.each do |ivar|
        cls.remove_instance_variable(ivar) if cls.instance_variable_defined?(ivar)
      end
    end
  end

  before { reset_compiler_caches! }

  def rbi_for(constant)
    reset_compiler_caches!
    pipeline = Tapioca::Dsl::Pipeline.new(
      requested_constants: [constant],
      requested_compilers: [described_class],
    )

    results = pipeline.run { |c, rbi| [c, rbi] }
    _, file = results.find { |c, _| c.equal?(constant) }
    file&.string
  end

  describe ".gather_constants" do
    it "includes classes that include Phlex::Sorbet" do
      expect(described_class.gather_constants).to include(SimpleComponent)
    end

    it "includes components without a Props class" do
      expect(described_class.gather_constants).to include(ComponentWithoutProps)
    end
  end

  describe "#decorate" do
    let(:rbi) { rbi_for(SimpleComponent) }

    it "emits a typed initialize method derived from Props" do
      expect(rbi).to include("def initialize(value:); end")
    end

    it "emits a typed self.new returning T.attached_class" do
      expect(rbi).to include("def self.new(value:); end")
    end

    it "emits a props method returning the Props class" do
      expect(rbi).to include("def props; end")
      expect(rbi).to match(/returns\(SimpleComponent::Props\)/)
    end

    it "does not emit per-prop accessor methods" do
      expect(rbi).not_to match(/^\s*def value; end/)
    end

    it "marks defaulted kwargs as optional" do
      defaulted = rbi_for(ComponentWithDefaults)
      expect(defaulted).to include(
        "def initialize(required_field:, optional_field: T.unsafe(nil)); end",
      )
    end

    it "orders required kwargs before optional ones regardless of Props declaration order" do
      reordered = rbi_for(ComponentWithOptionalBeforeRequired)
      expect(reordered).to include(
        "def initialize(class_name:, bordered: T.unsafe(nil)); end",
      )
      expect(reordered).to include(
        "def self.new(class_name:, bordered: T.unsafe(nil)); end",
      )
    end
  end

  describe "#decorate without a Props class" do
    let(:rbi) { rbi_for(ComponentWithoutProps) }

    it "does not emit a props method" do
      expect(rbi).not_to include("def props; end")
    end

    it "emits an empty initialize method" do
      expect(rbi).to include("def initialize; end")
    end
  end
end
