class CulturasController < ApplicationController
  before_action :set_cultura, only: %i[ show update destroy ]

  # GET /culturas
  def index
    @culturas = Cultura.all

    render json: @culturas
  end

  # GET /culturas/1
  def show
    render json: @cultura
  end

  # POST /culturas
  def create
    @cultura = Cultura.new(cultura_params)

    if @cultura.save
      render json: @cultura, status: :created, location: @cultura
    else
      render json: @cultura.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /culturas/1
  def update
    if @cultura.update(cultura_params)
      render json: @cultura
    else
      render json: @cultura.errors, status: :unprocessable_content
    end
  end

  # DELETE /culturas/1
  def destroy
    @cultura.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cultura
      @cultura = Cultura.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cultura_params
      params.expect(cultura: [ :nome, :descricao, :ciclo_medio_dias, :temperatura_min, :temperatura_max, :umidade_min, :umidade_max ])
    end
end
