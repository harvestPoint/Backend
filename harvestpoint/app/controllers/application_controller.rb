class ApplicationController < ActionController::API
  include Authenticatable

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  private

  def render_not_found(_exception = nil)
    render json: { error: "not_found", message: "Recurso inexistente" }, status: :not_found
  end

  def render_bad_request(_exception = nil)
    render json: { error: "bad_request", message: "Corpo da requisição JSON inválido" }, status: :bad_request
  end

  def render_parameter_missing(exception)
    render json: { error: "param_missing", message: exception.message }, status: :bad_request
  end

  def render_validation_errors(record)
    render json: {
      error: "invalid_data",
      message: "Dados inválidos",
      details: record.errors.full_messages
    }, status: :unprocessable_content
  end
end
