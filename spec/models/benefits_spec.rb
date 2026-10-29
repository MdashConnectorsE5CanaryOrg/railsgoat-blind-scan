# frozen_string_literal: true
require "spec_helper.rb"

describe Benefits do
  before(:all) do
    UserFixture.reset_all_users
    DatabaseCleaner.strategy = :transaction
  end

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

  describe ".save" do
    let(:data_path) { Rails.root.join("public", "data") }
    let(:uploaded_filename) { "$(id).pdf" }
    let(:uploaded_file) do
      instance_double(
        "UploadedFile",
        original_filename: uploaded_filename,
        read: "benefits payload"
      )
    end

    after do
      Dir.glob(data_path.join("*#{uploaded_filename}").to_s).each do |path|
        File.delete(path) if File.exist?(path)
      end
    end

    it "creates backups without invoking a shell when backup is enabled" do
      expect(Benefits).not_to receive(:system)

      Benefits.save(uploaded_file, true)

      backup_files = Dir.glob(data_path.join("bak*_#{uploaded_filename}").to_s)
      expect(File.exist?(data_path.join(uploaded_filename))).to be true
      expect(backup_files.length).to eq(1)
      expect(File.read(data_path.join(uploaded_filename))).to eq("benefits payload")
      expect(File.read(backup_files.first)).to eq("benefits payload")
    end
  end
end
