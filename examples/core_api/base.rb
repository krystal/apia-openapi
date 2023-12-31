# frozen_string_literal: true

require "core_api/authenticators/main_authenticator"
require "core_api/controllers/time_controller"
require "core_api/endpoints/test_endpoint"

module CoreAPI
  class Base < Apia::API

    authenticator Authenticators::MainAuthenticator

    name "Example API"

    scopes do
      add "time", "Allows time telling functions"
    end

    routes do
      schema

      get "time_formatting/incredibly/super/duper/long/format", controller: Controllers::TimeController,
                                                                endpoint: :format
      post "example/format", controller: Controllers::TimeController, endpoint: :format
      post "example/format_multiple", controller: Controllers::TimeController, endpoint: :format_multiple

      group :time do
        name "Time functions"
        description "Everything related to time elements"
        get "time/now", endpoint: Endpoints::TimeNowEndpoint
        post "time/now", endpoint: Endpoints::TimeNowEndpoint

        get "test/:object", endpoint: Endpoints::TestEndpoint
        post "test/:object", endpoint: Endpoints::TestEndpoint

        group :formatting do
          name "Formatting"
          controller Controllers::TimeController

          get "time/formatting/incredibly/super/duper/long/format", endpoint: :format
          post "time/formatting/format", endpoint: :format
        end
      end
    end

  end
end
