# frozen_string_literal: true

RSpec.describe Docxgen::Templates::Parser do
  describe "VARIABLE_REGEX" do
    subject(:regex) { Docxgen::Templates::Parser::VARIABLE_REGEX }

    it "allows correct variable names" do
      expect("{{ hello }}").to match(regex)
      expect("{{hello }}").to match(regex)
      expect("{{ hello}}").to match(regex)
      expect("{{hello}}").to match(regex)

      expect("{{ hello.world }}").to match(regex)
      expect("{{ Привет.Мир }}").to match(regex)
      expect("{{ _hello }}").to match(regex)
      expect("{{ __hello }}").to match(regex)
      expect("{{ __hello__ }}").to match(regex)
      expect("{{ Привет.Мир }}").to match(regex)
      expect("{{ a }}").to match(regex)

      # Considered valid because we remove multiple dots in paths later
      expect("{{ a...b }}").to match(regex)
    end

    it "disallows incorrect variable names" do
      expect("{{  }}").to_not match(regex)
      expect("{{ hello }").to_not match(regex)
      expect("{ hello }}").to_not match(regex)
      expect("{ hello }").to_not match(regex)

      expect("{{ .hello }}").to_not match(regex)
      expect("{{ hello. }}").to_not match(regex)
      expect("{{ hello world }}").to_not match(regex)
      expect("{{ !@#$%^&* }}").to_not match(regex)

      # First must not be digit and variable names cannot start with digit
      expect("{{ 0 }}").to_not match(regex)
      expect("{{ 0hello }}").to_not match(regex)
    end
  end

  describe ".find_variables" do
    it "returns empty array if there is no valid variables" do
      result = described_class.find_variables("")

      expect(result).to be_an_instance_of(Array)
      expect(result.size).to eq(0)
    end

    it "returns array of hashes with src and path" do
      result = described_class.find_variables("{{hello}} {{hello.world}} {{ Привет.Мир }}")

      expect(result).to be_an_instance_of(Array)
      expect(result.size).to eq(3)

      result.map do |h|
        expect(h).to be_an_instance_of(Hash)
        expect(h[:src]).to be_an_instance_of(String)
        expect(h[:path]).to be_an_instance_of(Array)
      end
    end
  end
end
