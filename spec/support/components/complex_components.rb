# frozen_string_literal: true
# typed: false

# Component with a nested T::Struct prop
class ComponentWithNestedStruct < Phlex::HTML
  include Phlex::Sorbet

  class Address < T::Struct
    const :street, String
    const :city, String
  end

  class Props < T::Struct
    const :name, String
    const :address, Address
  end

  def view_template
    span { "#{name} lives at #{address.street}, #{address.city}" }
  end
end

# Component with array and hash props
class ComponentWithComplexTypes < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :user_id, Integer
    const :tags, T::Array[String], default: []
    const :metadata, T::Hash[String, T.untyped], default: {}
  end

  def view_template
    span { "#{user_id}/#{tags.join(',')}/#{metadata.inspect}" }
  end
end

# Component with coercible primitive types
class ComponentWithCoercibleTypes < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :bool_field, T::Boolean
    const :int_field, Integer
    const :float_field, Float
    const :string_field, String
    const :symbol_field, Symbol
  end

  def view_template
    span { props.inspect }
  end
end

# Component using the props accessor (instead of direct field access)
class ComponentUsingPropsAccessor < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :value, Integer
  end

  def view_template
    span { (props.value + 10).to_s }
  end
end
