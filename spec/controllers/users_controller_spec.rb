# frozen_string_literal: true

require "spec_helper"

RSpec.describe UsersController, type: :controller do
  describe "POST #create" do
    let(:signup_params) do
      {
        user: {
          email: "new.user@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "New",
          last_name: "User",
          admin: true,
          auth_token: "attacker-controlled-token"
        }
      }
    end

    it "creates a user from allowed signup attributes" do
      expect {
        post :create, params: signup_params
      }.to change(User, :count).by(1)

      user = User.find_by!(email: "new.user@example.com")
      expect(user.first_name).to eq("New")
      expect(user.last_name).to eq("User")
      expect(user.admin).not_to be(true)
      expect(user.auth_token).not_to eq("attacker-controlled-token")
    end
  end
end
