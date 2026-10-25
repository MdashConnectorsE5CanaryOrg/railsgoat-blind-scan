# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid.
secret_key_base = ENV["SECRET_KEY_BASE"].presence || ENV["SECRET_TOKEN"].presence

if secret_key_base.blank?
  raise "SECRET_KEY_BASE or SECRET_TOKEN must be set"
end

Railsgoat::Application.config.secret_key_base = secret_key_base
