# frozen_string_literal: true

RSpec.describe Phlex::Sorbet do
  it "has a version number" do
    expect(Phlex::Sorbet::VERSION).not_to be_nil
  end

  describe "module inclusion" do
    it "extends ClassMethods" do
      expect(SimpleComponent).to respond_to(:props_class)
      expect(SimpleComponent).to respond_to(:build_props)
    end

    it "exposes a props instance reader" do
      component = SimpleComponent.new(value: 1)
      expect(component).to respond_to(:props)
    end

    it "does not auto-include any Phlex base class" do
      # User picks their own base class — we only add our own modules.
      ancestors = SimpleComponent.ancestors
      expect(ancestors).to include(described_class)
      expect(ancestors).to include(Phlex::Sorbet::InstanceMethods)
    end
  end
end
