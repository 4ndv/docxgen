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

    it "converts digits in path to integers, and strings to symbols" do
      result = described_class.find_variables("{{ hello.0.1.2.3.world }}")

      expect(result[0][:path]).to eq([:hello, 0, 1, 2, 3, :world])
    end
  end

  describe ".tr_substitute!" do
    it "replaces variable in paragraph without errors in strict mode" do
      doc = Docx::Document.open("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      _, errors = described_class.tr_substitute!(tr, { paragraph: "Hello, world!" }, strict: true)

      expect(errors.size).to eq(0)

      result_file = temp_docx_file("tr_substitute_replace")

      doc.save(result_file)

      result = Docx::Document.open(result_file)

      # Must find it again, otherwise changes are not present
      tr = result.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("Hello, world!")
    end

    it "returns error if data for variable wasn't provided" do
      doc = Docx::Document.open("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      _, errors = described_class.tr_substitute!(tr, {}, strict: true)

      expect(errors).to eq(["No value provided for variable: {{ paragraph }}"])
    end
  end
end
