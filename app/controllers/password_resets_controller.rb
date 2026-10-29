# frozen_string_literal: true
class PasswordResetsController < ApplicationController
  skip_before_action :authenticated

  RESET_TOKEN_TTL = 15.minutes

  def reset_password
    user = user_from_token(params[:token])

    if user && params[:password] && params[:confirm_password] && params[:password] == params[:confirm_password]
      user.password = params[:password]
      user.save!
      flash[:success] = "Your password has been reset please login"
      redirect_to :login
    else
      flash[:error] = "Error resetting your password. Please try again."
      redirect_to :login
    end
  end

  def confirm_token
    if !params[:token].nil? && is_valid?(params[:token])
      flash[:success] = "Password reset token confirmed! Please create a new password."
      render "password_resets/reset_password"
    else
      flash[:error] = "Invalid password reset token. Please try again."
      redirect_to :login
    end
  end

  def send_forgot_password
    @user = User.find_by_email(params[:email]) unless params[:email].nil?

    if @user && password_reset_mailer(@user)
      flash[:success] = "Password reset email sent to #{params[:email]}"
      redirect_to :login
    else
      flash[:error] = "There was an issue sending password reset email to #{params[:email]}".html_safe unless params[:email].nil?
    end
  end

  private

  def password_reset_mailer(user)
    token = generate_token(user)
    UserMailer.forgot_password(user.email, token).deliver
  end

  def generate_token(user)
    verifier.generate(
      user_id: user.id,
      purpose: "password_reset",
      issued_at: Time.current.to_i
    )
  end

  def is_valid?(token)
    @user = user_from_token(token)
    @user.present?
  end

  def user_from_token(token)
    payload = verifier.verified(token)
    return false unless payload.is_a?(Hash)
    return false unless payload["purpose"] == "password_reset" || payload[:purpose] == "password_reset"

    issued_at = payload["issued_at"] || payload[:issued_at]
    return false if issued_at.to_i < RESET_TOKEN_TTL.ago.to_i

    user_id = payload["user_id"] || payload[:user_id]
    User.find_by(id: user_id)
  end

  def verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON
    )
  end
end
