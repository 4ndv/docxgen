# frozen_string_literal: true

require "json"
require "docx"

module Docxgen
  class Generator
    attr_reader :doc

    def initialize(document)
      @doc = Docx::Document.open(document)
      @errors = []
      @rendered = false
    end

    def render(data, remove_missing: true)
      raise "Already rendered" if @rendered

      variables = JSON.parse(data.to_json, symbolize_names: true)

      paragraphs = @doc.paragraphs + collect_table_paragraphs

      paragraphs.each do |p|
        p.each_text_run do |tr|
          _, sub_errors = Templates::Parser.tr_substitute!(tr, variables, remove_missing: remove_missing)

          @errors.push(*sub_errors)
        end
      end

      @rendered = true

      valid?
    end

    def errors
      raise "Wasn't rendered" unless @rendered

      @errors
    end

    def valid?
      errors.size.zero?
    end

    def save(to)
      raise "Wasn't rendered" unless @rendered

      @doc.save(to)
    end

    def stream
      raise "Wasn't rendered" unless @rendered

      @doc.stream
    end

    private

      def collect_table_paragraphs
        # TODO: Refactor, maybe?

        @doc
          .tables
          .map(&:rows).flatten
          .map(&:cells).flatten
          .map(&:paragraphs).flatten
      end
  end
end
