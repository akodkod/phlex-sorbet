# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet edge cases" do
  it "supports nilable props with nil" do
    component = ComponentWithNilableProp.new(value: nil)
    expect(component.props.value).to be_nil
  end

  it "supports nilable props with a value" do
    component = ComponentWithNilableProp.new(value: 5)
    expect(component.props.value).to eq(5)
  end
end
