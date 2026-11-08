# frozen_string_literal: true
# NOTE:
# RailsGoat intentionally uses an insecure approach for key management.
# This is done to demonstrate bad practices for educational purposes.
#
# In real-world Rails applications:
# - Rails 5.1 supports encrypted secrets via config/secrets.yml
# - Rails 5.2+ supports encrypted credentials via credentials.yml.enc
# - Secrets are commonly provided via environment variables (ENV)
#
# Hardcoding keys or omitting secure secret management must NEVER be done
# in production applications.
KEY = ENV.fetch("APP_ENCRYPTION_KEY") do
  raise "APP_ENCRYPTION_KEY must be set"
end
