# frozen_string_literal: true

RSpec.describe "Phlex::Sorbet RSpec matchers" do
  describe "have_prop" do
    it "passes when the prop exists" do
      expect(SimpleComponent).to have_prop(:value)
    end

    it "passes when the prop has the expected type" do
      expect(SimpleComponent).to have_prop(:value, Integer)
    end

    it "fails when the prop does not exist" do
      expect { expect(SimpleComponent).to have_prop(:missing) }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "supports with_default" do
      expect(ComponentWithDefaults).to have_prop(:optional_field, T::Boolean).with_default(false)
    end

    it "fails with_default when the default does not match" do
      expect { expect(ComponentWithDefaults).to have_prop(:optional_field).with_default(true) }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe "have_props" do
    it "passes for a hash of props" do
      expect(ComponentWithDefaults).to have_props(required_field: String, optional_field: T::Boolean)
    end

    it "supports the chained syntax" do
      expect(ComponentWithDefaults).to have_props(:required_field, String).and_prop(:optional_field, T::Boolean)
    end
  end

  describe "accept_props" do
    it "passes when props are valid" do
      expect(SimpleComponent).to accept_props(value: 1)
    end

    it "fails when props are invalid" do
      expect { expect(SimpleComponent).to accept_props(value: "abc") }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe "reject_props" do
    it "passes when props are rejected" do
      expect(SimpleComponent).to reject_props(value: "abc")
    end

    it "supports with_error" do
      expect(SimpleComponent).to reject_props(value: "abc")
        .with_error(Phlex::Sorbet::InvalidPropsError)
    end

    it "fails when the props are accepted" do
      expect { expect(SimpleComponent).to reject_props(value: 1) }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end
