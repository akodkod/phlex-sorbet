# frozen_string_literal: true
# typed: false

# Component whose `Props` constant is not a T::Struct
class ComponentWithInvalidPropsClass < Phlex::HTML
  include Phlex::Sorbet

  class Props
    # Intentionally not a T::Struct, used to verify validation behavior.
    def self.marker
      :not_a_struct
    end
  end

  def view_template
    p { "never renders" }
  end
end
