# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet prop coercion" do
  # Coercion is provided by sorbet-schema's HashSerializer.

  it "coerces 'true' string to true" do
    component = ComponentWithCoercibleTypes.new(
      bool_field: "true",
      int_field: 1,
      float_field: 1.0,
      string_field: "x",
      symbol_field: "x",
    )
    expect(component.props.bool_field).to be(true)
  end

  it "coerces 'false' string to false" do
    component = ComponentWithCoercibleTypes.new(
      bool_field: "false",
      int_field: 1,
      float_field: 1.0,
      string_field: "x",
      symbol_field: "x",
    )
    expect(component.props.bool_field).to be(false)
  end

  it "coerces numeric strings to Integer" do
    component = ComponentWithCoercibleTypes.new(
      bool_field: true,
      int_field: "42",
      float_field: 1.0,
      string_field: "x",
      symbol_field: "x",
    )
    expect(component.props.int_field).to eq(42)
  end

  it "coerces numeric strings to Float" do
    component = ComponentWithCoercibleTypes.new(
      bool_field: true,
      int_field: 1,
      float_field: "3.14",
      string_field: "x",
      symbol_field: "x",
    )
    expect(component.props.float_field).to eq(3.14)
  end

  it "coerces strings to Symbol" do
    component = ComponentWithCoercibleTypes.new(
      bool_field: true,
      int_field: 1,
      float_field: 1.0,
      string_field: "x",
      symbol_field: "my_sym",
    )
    expect(component.props.symbol_field).to eq(:my_sym)
  end

  it "raises InvalidPropsError when a string cannot be coerced to Integer" do
    expect do
      ComponentWithCoercibleTypes.new(
        bool_field: true,
        int_field: "not_a_number",
        float_field: 1.0,
        string_field: "x",
        symbol_field: "x",
      )
    end.to raise_error(Phlex::Sorbet::InvalidPropsError, /Invalid props/)
  end

  it "supports passing string keys directly" do
    component = ComponentWithCoercibleTypes.new(
      "bool_field" => true,
      "int_field" => 1,
      "float_field" => 1.0,
      "string_field" => "x",
      "symbol_field" => "x",
    )
    expect(component.props.int_field).to eq(1)
  end
end
