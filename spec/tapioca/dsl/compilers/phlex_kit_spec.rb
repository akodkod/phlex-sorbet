# frozen_string_literal: true
# typed: false

require "tapioca/internal"
require "tapioca/dsl/pipeline"

RSpec.describe Tapioca::Dsl::Compilers::PhlexKit do
  def rbi_for(constant)
    pipeline = Tapioca::Dsl::Pipeline.new(
      requested_constants: [constant],
      requested_compilers: [described_class],
    )

    results = pipeline.run { |c, rbi| [c, rbi] }
    _, file = results.find { |c, _| c.equal?(constant) }
    file&.string
  end

  describe ".gather_constants" do
    it "includes modules that extend Phlex::Kit" do
      expect(described_class.gather_constants).to include(KitFixtures)
    end

    it "includes nested modules auto-extended by Phlex::Kit" do
      expect(described_class.gather_constants).to include(KitFixtures::Nested)
    end

    it "excludes Phlex::Kit itself" do
      gathered = described_class.gather_constants.to_a
      expect(gathered.any? { |m| m.equal?(Phlex::Kit) }).to be(false)
    end

    it "excludes regular component classes" do
      gathered = described_class.gather_constants.to_a
      expect(gathered.any? { |m| m.equal?(KitFixtures::Card) }).to be(false)
    end
  end

  describe "#decorate" do
    let(:rbi) { rbi_for(KitFixtures) }

    it "generates an instance method for each registered component" do
      expect(rbi).to include("def Button(*args, **kwargs, &block); end")
    end

    it "generates a singleton method for each registered component" do
      expect(rbi).to include("def self.Button(*args, **kwargs, &block); end")
    end

    it "emits typed kwargs for components that include Phlex::Sorbet" do
      expect(rbi).to include("def Card(title:, &block); end")
      expect(rbi).to include("def self.Card(title:, &block); end")
    end

    it "emits defaulted kwargs for typed components with default props" do
      expect(rbi).to include("def Alert(message:, variant: T.unsafe(nil), &block); end")
      expect(rbi).to include("def self.Alert(message:, variant: T.unsafe(nil), &block); end")
    end

    it "orders required kwargs before optional ones regardless of Props declaration order" do
      expect(rbi).to include("def Card2(class_name:, bordered: T.unsafe(nil), &block); end")
      expect(rbi).to include("def self.Card2(class_name:, bordered: T.unsafe(nil), &block); end")
    end

    it "wraps the methods on the kit module" do
      expect(rbi).to include("module KitFixtures")
    end

    it "does not emit methods for nested kit modules" do
      expect(rbi).not_to include("Badge")
    end

    it "emits methods for components on the nested kit module" do
      nested = rbi_for(KitFixtures::Nested)
      expect(nested).to include("def Badge(*args, **kwargs, &block); end")
      expect(nested).to include("def self.Badge(*args, **kwargs, &block); end")
    end
  end
end
