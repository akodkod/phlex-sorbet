# frozen_string_literal: true
# typed: false

# Component with a nilable prop
class ComponentWithNilableProp < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :value, T.nilable(Integer)
  end

  def view_template
    span { props.value.to_s }
  end
end
