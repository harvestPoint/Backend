module Api
  class HealthController < ApplicationController
    def show
      db_status = check_database_connection
      status_code = db_status == "connected" ? :ok : :service_unavailable

      render json: {
        status: status_code == :ok ? "healthy" : "degraded",
        service: "harvestpoint-api",
        environment: Rails.env,
        database: db_status,
        timestamp: Time.current.iso8601
      }, status: status_code
    end

    private

    def check_database_connection
      ActiveRecord::Base.connection.execute("SELECT 1")
      "connected"
    rescue => e
      "disconnected: #{e.message}"
    end
  end
end
