# frozen_string_literal: true
require "spec_helper.rb"

describe Benefits do
  before(:all) do
    UserFixture.reset_all_users
    DatabaseCleaner.strategy = :transaction
  end

  let(:upload_dir) { Rails.root.join("public", "data") }

  after(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  it "can be instantiated" do
    expect(Benefits.new).to be_an_instance_of(Benefits)
  end

  it "name can be updated" do
    new_name = "Bobby"
    user = User.all.first
    user.first_name = new_name
    user.save!
    expect(User.all.first.first_name).to eq(new_name)
  end

  describe ".validated_filename" do
    it "accepts a single path segment" do
      expect(Benefits.validated_filename("benefits.pdf")).to eq("benefits.pdf")
    end

    it "rejects path traversal markers" do
      expect { Benefits.validated_filename("../../tmp/pwn.pdf") }.to raise_error(ArgumentError, "invalid filename")
      expect { Benefits.validated_filename("/tmp/pwn.pdf") }.to raise_error(ArgumentError, "invalid filename")
      expect { Benefits.validated_filename("..") }.to raise_error(ArgumentError, "invalid filename")
    end
  end

  describe ".save" do
    after do
      Dir.glob(upload_dir.join("benefits-spec-*")) { |path| File.delete(path) }
      Dir.glob(upload_dir.join("bak*_benefits-spec-*")) { |path| File.delete(path) }
    end

    it "stores a valid upload beneath public/data" do
      file = double("upload", original_filename: "benefits-spec-valid.pdf", read: "pdf-data")

      Benefits.save(file)

      expect(File.binread(upload_dir.join("benefits-spec-valid.pdf"))).to eq("pdf-data")
    end

    it "rejects filenames containing path components" do
      file = double("upload", original_filename: "../../benefits-spec-escape.pdf")

      expect { Benefits.save(file) }.to raise_error(ArgumentError, "invalid filename")
      expect(File.exist?(upload_dir.join("benefits-spec-escape.pdf"))).to eq(false)
    end
  end
end
