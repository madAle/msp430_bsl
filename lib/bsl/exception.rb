# frozen_string_literal: true

module Bsl
  class Exception < StandardError
    def initialize(message)
      super(message)
    end
  end
end
