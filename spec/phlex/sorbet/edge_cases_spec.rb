# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet edge cases" do
  it "supports nilable props with nil" do
    component = ComponentWithNilableProp.new(value: nil)
    expect(component.value).to be_nil
  end

  it "supports nilable props with a value" do
    component = ComponentWithNilableProp.new(value: 5)
    expect(component.value).to eq(5)
  end

  it "exposes a prop named :props as the field value (shadows the struct accessor)" do
    component = ComponentWithConflictingPropName.new(props: "the-value", other: "x")
    expect(component.props).to eq("the-value")
    expect(component.other).to eq("x")
    expect(component.instance_variable_get(:@props))
      .to be_a(ComponentWithConflictingPropName::Props)
  end
end
