# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet props detection" do
  describe ".props_class" do
    it "returns the Props class when defined as T::Struct" do
      expect(SimpleComponent.props_class).to eq(SimpleComponent::Props)
    end

    it "returns nil when no Props const is defined" do
      expect(ComponentWithoutProps.props_class).to be_nil
    end

    it "memoizes the lookup" do
      first = SimpleComponent.props_class
      second = SimpleComponent.props_class
      expect(first).to equal(second)
    end

    it "raises PropsNotDefinedError when Props is not a T::Struct" do
      expect { ComponentWithInvalidPropsClass.props_class }
        .to raise_error(Phlex::Sorbet::PropsNotDefinedError, /must inherit from T::Struct/)
    end
  end
end
