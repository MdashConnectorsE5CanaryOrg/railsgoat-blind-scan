# frozen_string_literal: true

require "spec_helper"

describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: current_user&.email.to_s
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  it "uses the session-backed user id" do
    user = UserFixture.normal_user

    session[:user_id] = user.id
    get :index

    expect(response.body).to eq(user.email)
  end

  it "ignores auth_token cookies when there is no authenticated session" do
    user = UserFixture.admin_user

    cookies[:auth_token] = user.auth_token
    get :index

    expect(response.body).to eq("")
  end
end
