# frozen_string_literal: true
# typed: false

# Component with a nilable prop
class ComponentWithNilableProp < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :value, T.nilable(Integer)
  end

  def view_template
    span { value.to_s }
  end
end

# Component whose Props happens to define a `props` field, conflicting with the accessor name.
# We expect the auto-defined accessor to be skipped (the `props` reader stays).
class ComponentWithConflictingPropName < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :props, String # conflicts with InstanceMethods#props
    const :other, String
  end

  def view_template
    span { "#{other}/#{props}" }
  end
end
