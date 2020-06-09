# frozen_string_literal: true

module Docxgen
  class Generator
    def initialize(document)
      @doc = Docx::Document.open(document)
    end

    def render(data)
      variables = HashWithIndifferentAccess.new(data)
    end

    def errors
    end

    def valid?
    end
  end
end
