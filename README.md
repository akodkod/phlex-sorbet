# Phlex::Sorbet

Type-safe `Props` for [Phlex](https://www.phlex.fun/) views and components, powered by [sorbet-schema](https://github.com/maxveldink/sorbet-schema).

## Quick Example

```ruby
class UserCard < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :user_id, Integer
    const :show_email, T::Boolean, default: false
  end

  def view_template
    div do
      span { "User ##{user_id}" }
      span { "email visible" } if show_email
    end
  end
end

UserCard.new(user_id: 1).call                       # => "<div><span>User #1</span></div>"
UserCard.new(user_id: 1, show_email: true).call     # => "<div>...<span>email visible</span></div>"
UserCard.new(user_id: "1").call                     # OK — coerced via sorbet-schema
UserCard.new(user_id: "abc").call                   # => raises Phlex::Sorbet::InvalidPropsError
UserCard.new                                        # => raises Phlex::Sorbet::InvalidPropsError (missing user_id)
```

## Features

- **Direct prop access** — use `user_id` inside `view_template` instead of `props.user_id`.
- **Type safety** — props are validated against your `Props` `T::Struct` at instantiation time.
- **Coercion** — strings from controller params are coerced to the declared type via [sorbet-schema](https://github.com/maxveldink/sorbet-schema).
- **Nested `T::Struct` props** — fully supported via sorbet-schema.
- **Optional Props** — components can omit the `Props` class when they take no props.
- **Backward-friendly accessor** — `props.user_id` still works.
- **RSpec matchers** — `have_prop`, `have_props`, `accept_props`, `reject_props`.
- **Tapioca DSL compiler** — generates RBI for `initialize` and prop accessors.

## Installation

```bash
bundle add phlex-sorbet
```

Or:

```bash
gem install phlex-sorbet
```

## Usage

### Basic component with props

```ruby
class Button < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :label, String
    const :variant, Symbol, default: :primary
  end

  def view_template
    button(class: "btn btn-#{variant}") { label }
  end
end

Button.new(label: "Save").call
Button.new(label: "Cancel", variant: :secondary).call
```

### Component without props

The `Props` constant is optional. Components without props work as usual:

```ruby
class Spinner < Phlex::HTML
  include Phlex::Sorbet

  def view_template
    div(class: "spinner")
  end
end

Spinner.new.call
```

### Complex types

```ruby
class TagList < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :tags, T::Array[String]
    const :filters, T::Hash[String, T.untyped], default: {}
  end

  def view_template
    ul do
      tags.each { |t| li { t } }
    end
  end
end

TagList.new(tags: ["ruby", "phlex"]).call
```

### Nested `T::Struct` props

```ruby
class Greeting < Phlex::HTML
  include Phlex::Sorbet

  class User < T::Struct
    const :name, String
    const :email, String
  end

  class Props < T::Struct
    const :user, User
    const :show_email, T::Boolean, default: false
  end

  def view_template
    p { "Hi #{user.name}" }
    p { user.email } if show_email
  end
end

Greeting.new(user: Greeting::User.new(name: "Ada", email: "ada@example.com")).call
```

### Using the `props` accessor

If you'd rather access props through the struct, the `props` reader is always available:

```ruby
class Card < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :title, String
  end

  def view_template
    h2 { props.title }
  end
end
```

### Coercion (string → typed value)

Because [sorbet-schema](https://github.com/maxveldink/sorbet-schema) handles deserialization, props passed as strings (e.g. from controller params) are coerced to the declared type:

```ruby
UserCard.new(user_id: "42")            # user_id == 42
ToggleSwitch.new(enabled: "true")      # enabled == true
```

If coercion fails, `Phlex::Sorbet::InvalidPropsError` is raised.

## RSpec matchers

In your `spec_helper.rb` or `rails_helper.rb`:

```ruby
require "phlex/sorbet/rspec"
```

The matchers are auto-included into RSpec.

### `have_prop`

```ruby
expect(UserCard).to have_prop(:user_id)
expect(UserCard).to have_prop(:user_id, Integer)
expect(UserCard).to have_prop(:show_email, T::Boolean).with_default(false)
```

### `have_props`

```ruby
expect(UserCard).to have_props(user_id: Integer, show_email: T::Boolean)
expect(UserCard).to have_props(:user_id, Integer).and_prop(:show_email, T::Boolean)
```

### `accept_props`

```ruby
expect(UserCard).to accept_props(user_id: 1)
expect(UserCard).to accept_props(user_id: 1, show_email: true)
```

### `reject_props`

```ruby
expect(UserCard).to reject_props(user_id: "abc")
expect(UserCard).to reject_props(user_id: "abc")
  .with_error(Phlex::Sorbet::InvalidPropsError)
```

### Example test

```ruby
RSpec.describe UserCard do
  describe "Props" do
    it { is_expected.to have_prop(:user_id, Integer) }
    it { is_expected.to have_prop(:show_email, T::Boolean).with_default(false) }

    it { is_expected.to accept_props(user_id: 1) }
    it { is_expected.to reject_props(user_id: "abc") }
  end

  it "renders the user id" do
    expect(UserCard.new(user_id: 7).call).to include("User #7")
  end
end
```

## Tapioca DSL compiler

This gem ships a Tapioca DSL compiler that generates RBI files describing each component's `initialize` signature and per-prop accessors.

```bash
bundle exec tapioca dsl
```

For a component:

```ruby
class UserCard < Phlex::HTML
  include Phlex::Sorbet

  class Props < T::Struct
    const :user_id, Integer
    const :show_email, T::Boolean, default: false
  end
end
```

It generates RBI like:

```ruby
class UserCard
  sig { returns(Integer) }
  def user_id; end

  sig { returns(T::Boolean) }
  def show_email; end

  sig { params(user_id: Integer, show_email: T::Boolean).void }
  def initialize(user_id:, show_email: T.unsafe(nil)); end
end
```

## License

MIT.
