# frozen_string_literal: true

RSpec.describe Docxgen::Generator do
  describe ".render" do
    it "replaces text in paragraph" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render(paragraph: "Hello, world!")

      expect(gen.valid?).to be(true)

      result_file = temp_docx_file("gen_render_paragraph")

      gen.save(result_file)

      result = Docx::Document.open(result_file)

      # Must find it again, otherwise changes are not present
      tr = result.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("Hello, world!")
    end

    it "replaces text in table; supports arrays" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_table.docx")

      cells = gen.doc.tables.first.rows[1].cells.map(&:to_s)

      expect(cells).to eq(["{{ cols.0 }}", "{{ cols.1 }}", "{{ cols.2 }}"])

      cols = ["Hello", "World", "Lol"]

      gen.render(cols: ["Hello", "World", "Lol"])

      expect(gen.valid?).to be(true)

      result_file = temp_docx_file("gen_render_table")

      gen.save(result_file)

      result = Docx::Document.open(result_file)

      # Must find it again, otherwise changes are not present
      cells = result.tables.first.rows[1].cells.map(&:to_s)

      expect(cells).to eq(cols)
    end

    it "symbolizes keys" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render({ "paragraph": "lol" }, remove_missing: false)

      expect(gen.valid?).to be(true)
    end

    it "returns false if any errors" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      result = gen.render({ error: "lol" })

      expect(result).to be(false)
    end

    it "raises if rendered second time" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render({ paragraph: "lol" })

      expect { gen.render({}) }.to raise_exception
    end
  end

  describe ".errors" do
    it "returns array" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render({ error: "lol" })

      expect(gen.errors).to be_instance_of(Array)
    end

    it "raises if wasn't rendered" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      expect { gen.errors }.to raise_exception
    end
  end

  describe ".valid?" do
    it "return false if there is any errors" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render({ error: "lol" })

      expect(gen.errors.size).to be(1)
      expect(gen.valid?).to be(false)
    end

    it "return true if there is no errors" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      tr = gen.doc.paragraphs.first.text_runs.first

      expect(tr.to_s).to eq("{{ paragraph }}")

      gen.render({ paragraph: "lol" })

      expect(gen.errors.size).to be(0)
      expect(gen.valid?).to be(true)
    end

    it "raises if wasn't rendered" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      expect { gen.valid? }.to raise_exception
    end
  end

  describe ".save" do
    it "creates file" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      gen.render({})

      result_file = temp_docx_file("gen_render_paragraph")

      gen.save(result_file)

      expect(File.exist?(result_file)).to be(true)
    end

    it "raises if wasn't rendered" do
      gen = described_class.new("#{RSPEC_ROOT}/fixtures/single_paragraph.docx")

      expect { gen.save("123.docx") }.to raise_exception
    end
  end
end
