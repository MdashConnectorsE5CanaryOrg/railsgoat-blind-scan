# frozen_string_literal: true
require "spec_helper.rb"

describe User do
  before(:all) do
    UserFixture.reset_all_users
    DatabaseCleaner.strategy = :transaction
  end

  after(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  it "can be instantiated" do
    expect(User.new).to be_an_instance_of(User)
  end

  it "should require a email" do
    expect(User.new(email: "")).not_to be_valid
  end

  it "should require valid email" do
    expect(User.new(email: "@gmail.com")).not_to be_valid
  end

  it "should require unique email" do
    user = User.all.first
    expect(User.new(email: user.email)).not_to be_valid
  end

  it "name can be updated" do
    new_name = "Bobby"
    user = User.all.first
    user.first_name = new_name
    user.save!
    expect(User.all.first.first_name).to eq(new_name)
  end

  it "rotates auth_token when password changes" do
    user = UserFixture.normal_user
    original_token = user.auth_token
    new_password = "nEw P@ssw0rd!"

    user.password = new_password
    user.password_confirmation = new_password
    user.save!

    expect(user.reload.auth_token).not_to eq(original_token)
  end

  it "does not rotate auth_token for profile-only updates" do
    user = UserFixture.normal_user
    original_token = user.auth_token

    user.update!(first_name: "Updated")

    expect(user.reload.auth_token).to eq(original_token)
  end
end
