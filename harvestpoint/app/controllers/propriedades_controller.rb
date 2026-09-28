class PropriedadesController < ApplicationController
  before_action :set_propriedade, only: %i[ show update destroy ]

  # GET /propriedades
  def index
    @propriedades = Propriedade.all

    render json: @propriedades
  end

  # GET /propriedades/1
  def show
    render json: @propriedade
  end

  # POST /propriedades
  def create
    @propriedade = Propriedade.new(propriedade_params)

    if @propriedade.save
      render json: @propriedade, status: :created, location: @propriedade
    else
      render json: @propriedade.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /propriedades/1
  def update
    if @propriedade.update(propriedade_params)
      render json: @propriedade
    else
      render json: @propriedade.errors, status: :unprocessable_content
    end
  end

  # DELETE /propriedades/1
  def destroy
    @propriedade.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_propriedade
      @propriedade = Propriedade.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def propriedade_params
      params.expect(propriedade: [ :usuario_id, :nome, :municipio, :localizacao, :area_total ])
    end
end
