class AlertaController < ApplicationController
  before_action :set_alertum, only: %i[ show update destroy ]

  # GET /alerta
  def index
    @alerta = Alertum.all

    render json: @alerta
  end

  # GET /alerta/1
  def show
    render json: @alertum
  end

  # POST /alerta
  def create
    @alertum = Alertum.new(alertum_params)

    if @alertum.save
      render json: @alertum, status: :created, location: @alertum
    else
      render json: @alertum.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /alerta/1
  def update
    if @alertum.update(alertum_params)
      render json: @alertum
    else
      render json: @alertum.errors, status: :unprocessable_content
    end
  end

  # DELETE /alerta/1
  def destroy
    @alertum.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alertum
      @alertum = Alertum.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def alertum_params
      params.expect(alertum: [ :lote_id, :sensor_id, :tipo_alerta, :mensagem, :data_hora, :resolvido ])
    end
end
