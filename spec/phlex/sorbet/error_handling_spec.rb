# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet error handling" do
  describe "invalid props" do
    it "raises InvalidPropsError when a required prop is missing" do
      expect { SimpleComponent.new }
        .to raise_error(Phlex::Sorbet::InvalidPropsError, /Invalid props/)
    end

    it "raises InvalidPropsError when a prop has the wrong type" do
      expect { SimpleComponent.new(value: "not an integer that can't coerce: abc") }
        .to raise_error(Phlex::Sorbet::InvalidPropsError)
    end
  end

  describe "props passed to a component without Props" do
    it "raises PropsNotDefinedError" do
      expect { ComponentWithoutProps.new(foo: 1) }
        .to raise_error(Phlex::Sorbet::PropsNotDefinedError, /does not define a Props class/)
    end

    it "permits zero-kwarg construction" do
      expect { ComponentWithoutProps.new }.not_to raise_error
    end
  end

  describe "invalid Props class" do
    it "raises PropsNotDefinedError when Props is not a T::Struct" do
      expect { ComponentWithInvalidPropsClass.new(anything: 1) }
        .to raise_error(Phlex::Sorbet::PropsNotDefinedError)
    end
  end
end
