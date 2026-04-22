# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet prop access" do
  describe "direct prop access" do
    it "exposes each prop as a method on the instance" do
      component = SimpleComponent.new(value: 7)
      expect(component.value).to eq(7)
    end

    it "renders using direct prop access" do
      expect(SimpleComponent.new(value: 42).call).to include("42")
    end

    it "exposes nested struct fields through the parent prop" do
      address = ComponentWithNestedStruct::Address.new(street: "Main St", city: "Portland")
      component = ComponentWithNestedStruct.new(name: "Alice", address: address)
      expect(component.call).to include("Alice lives at Main St, Portland")
    end

    it "honors default values" do
      component = ComponentWithDefaults.new(required_field: "hi")
      expect(component.optional_field).to be(false)
      expect(component.required_field).to eq("hi")
    end
  end

  describe "props accessor (still available)" do
    it "returns the typed Props instance" do
      component = ComponentUsingPropsAccessor.new(value: 5)
      expect(component.props).to be_a(ComponentUsingPropsAccessor::Props)
      expect(component.props.value).to eq(5)
    end

    it "returns nil for components without Props" do
      expect(ComponentWithoutProps.new.props).to be_nil
    end

    it "renders using the props accessor" do
      expect(ComponentUsingPropsAccessor.new(value: 5).call).to include("15")
    end
  end

  describe "complex types" do
    it "supports arrays and hashes" do
      component = ComponentWithComplexTypes.new(
        user_id: 99,
        tags: ["a", "b"],
        metadata: { "k" => "v" },
      )
      expect(component.tags).to eq(["a", "b"])
      expect(component.metadata).to eq({ "k" => "v" })
    end
  end
end
