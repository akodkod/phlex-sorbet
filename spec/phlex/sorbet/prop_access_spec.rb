# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet prop access" do
  describe "props accessor" do
    it "returns the typed Props instance" do
      component = SimpleComponent.new(value: 7)
      expect(component.props).to be_a(SimpleComponent::Props)
      expect(component.props.value).to eq(7)
    end

    it "returns nil for components without Props" do
      expect(ComponentWithoutProps.new.props).to be_nil
    end

    it "renders using the props accessor" do
      expect(SimpleComponent.new(value: 42).call).to include("42")
    end

    it "exposes nested struct fields through the parent prop" do
      address = ComponentWithNestedStruct::Address.new(street: "Main St", city: "Portland")
      component = ComponentWithNestedStruct.new(name: "Alice", address: address)
      expect(component.call).to include("Alice lives at Main St, Portland")
    end

    it "honors default values" do
      component = ComponentWithDefaults.new(required_field: "hi")
      expect(component.props.optional_field).to be(false)
      expect(component.props.required_field).to eq("hi")
    end
  end

  describe "no per-prop accessor methods" do
    it "does not define a singleton method per prop on the instance" do
      component = SimpleComponent.new(value: 7)
      expect(component).not_to respond_to(:value)
    end
  end

  describe "complex types" do
    it "supports arrays and hashes" do
      component = ComponentWithComplexTypes.new(
        user_id: 99,
        tags: ["a", "b"],
        metadata: { "k" => "v" },
      )
      expect(component.props.tags).to eq(["a", "b"])
      expect(component.props.metadata).to eq({ "k" => "v" })
    end
  end
end
