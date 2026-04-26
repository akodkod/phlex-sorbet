# frozen_string_literal: true
# typed: false

# Component with a simple integer prop
class SimpleComponent < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :value, Integer
  end

  def view_template
    span { props.value.to_s }
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
    span { "#{props.required_field}: #{props.optional_field}" }
  end
end

# Component whose Props declares an optional field before a required one.
# Used to verify the compiler reorders kwargs so required ones come first.
class ComponentWithOptionalBeforeRequired < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :bordered, T::Boolean, default: false
    const :class_name, T.nilable(String)
  end

  def view_template
    div { props.class_name.to_s }
  end
end

# Component without any Props
class ComponentWithoutProps < Phlex::HTML
  include Phlex::Sorbet

  def view_template
    p { "no props" }
  end
end
