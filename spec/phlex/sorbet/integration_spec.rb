# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet rendering integration" do
  it "renders a simple component" do
    expect(SimpleComponent.new(value: 1).call).to include("<span>1</span>")
  end

  it "renders a component with defaults" do
    html = ComponentWithDefaults.new(required_field: "hello").call
    expect(html).to include("hello: false")
  end

  it "renders a component with no props" do
    expect(ComponentWithoutProps.new.call).to include("no props")
  end

  it "renders a component with nested structs" do
    address = ComponentWithNestedStruct::Address.new(street: "1st", city: "Sea")
    expect(ComponentWithNestedStruct.new(name: "Bob", address: address).call)
      .to include("Bob lives at 1st, Sea")
  end
end
