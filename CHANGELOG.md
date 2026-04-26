## [Unreleased]

### Breaking changes

- Removed automatic per-prop accessor methods on component instances. Props
  must now be read through the `props` accessor (e.g. `props.user_id` instead
  of `user_id`). The Tapioca DSL compiler emits a typed `props` method that
  returns the component's `Props` struct so calls type-check under Sorbet.

## [0.1.0]

- Initial release
