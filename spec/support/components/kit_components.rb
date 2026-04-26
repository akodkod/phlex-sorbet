# frozen_string_literal: true
# typed: false

# Fixture module that uses Phlex::Kit. The PhlexKit Tapioca DSL compiler
# should detect this module and emit RBI methods for each registered
# component constant.
module KitFixtures
  extend Phlex::Kit

  class Button < Phlex::HTML
    def view_template
      button { "Click" }
    end
  end

  class Card < Phlex::HTML
    include Phlex::Sorbet

    class Props < T::Struct
      const :title, String
    end

    def view_template
      div { title }
    end
  end

  class Alert < Phlex::HTML
    include Phlex::Sorbet

    class Props < T::Struct
      const :message, String
      const :variant, String, default: "info"
    end

    def view_template
      div { message }
    end
  end

  # Optional kwarg declared before a required one — exercises kwarg
  # reordering in the generated kit methods.
  class Card2 < Phlex::HTML
    include Phlex::Sorbet

    class Props < T::Struct
      const :bordered, T::Boolean, default: false
      const :class_name, T.nilable(String)
    end

    def view_template
      div { props.class_name.to_s }
    end
  end
end

# Nested kit module — `Phlex::Kit#const_added` automatically extends nested
# modules with `Phlex::Kit`, so the compiler should also process this one.
module KitFixtures
  module Nested
    class Badge < Phlex::HTML
      def view_template
        span { "badge" }
      end
    end
  end
end
