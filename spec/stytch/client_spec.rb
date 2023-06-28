# frozen_string_literal: true
require_relative "./shared_examples_for_clients"

RSpec.describe Stytch::Client do
  it_behaves_like "a client"
end
