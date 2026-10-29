# frozen_string_literal: true
require "spec_helper"

RSpec.describe PasswordResetsController, type: :controller do
  let!(:user) do
    User.create!(
      first_name: "Reset",
      last_name: "Tester",
      email: "reset@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  def password_reset_token_for(target_user, issued_at: Time.current.to_i, purpose: "password_reset")
    verifier = ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON
    )

    verifier.generate(
      user_id: target_user.id,
      purpose: purpose,
      issued_at: issued_at
    )
  end

  describe "GET #confirm_token" do
    it "rejects the legacy deterministic token format" do
      legacy_token = "#{user.id}-#{Digest::MD5.hexdigest(user.email)}"

      get :confirm_token, params: {token: legacy_token}

      expect(response).to redirect_to(:login)
      expect(flash[:error]).to eq("Invalid password reset token. Please try again.")
    end

    it "accepts a server-signed token within the reset window" do
      token = password_reset_token_for(user)

      get :confirm_token, params: {token: token}

      expect(response).to render_template("password_resets/reset_password")
      expect(assigns(:user)).to eq(user)
    end

    it "rejects expired tokens" do
      token = password_reset_token_for(user, issued_at: 16.minutes.ago.to_i)

      get :confirm_token, params: {token: token}

      expect(response).to redirect_to(:login)
      expect(flash[:error]).to eq("Invalid password reset token. Please try again.")
    end
  end

  describe "POST #reset_password" do
    it "resets the password when given a valid signed token" do
      token = password_reset_token_for(user)

      post :reset_password, params: {
        token: token,
        password: "newsecret",
        confirm_password: "newsecret"
      }

      expect(response).to redirect_to(:login)
      expect(flash[:success]).to eq("Your password has been reset please login")
      expect(user.reload.password).to eq(Digest::MD5.hexdigest("newsecret"))
    end

    it "does not reset the password with an invalid token" do
      original_password = user.password

      post :reset_password, params: {
        token: "forged-token",
        password: "newsecret",
        confirm_password: "newsecret"
      }

      expect(response).to redirect_to(:login)
      expect(flash[:error]).to eq("Error resetting your password. Please try again.")
      expect(user.reload.password).to eq(original_password)
    end
  end
end
