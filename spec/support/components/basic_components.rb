# frozen_string_literal: true
# typed: false

# Component with a simple integer prop
class SimpleComponent < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :value, Integer
  end

  def view_template
    span { value.to_s }
  end
end

# Component with a default value
class ComponentWithDefaults < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :required_field, String
    const :optional_field, T::Boolean, default: false
  end

  def view_template
    span { "#{required_field}: #{optional_field}" }
  end
end

# Component without any Props
class ComponentWithoutProps < Phlex::HTML
  include Phlex::Sorbet

  def view_template
    p { "no props" }
  end
end
