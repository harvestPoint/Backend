class RecomendacaoColheitaController < ApplicationController
  before_action :set_recomendacao_colheitum, only: %i[ show update destroy ]

  # GET /recomendacao_colheita
  def index
    @recomendacao_colheita = RecomendacaoColheitum.all

    render json: @recomendacao_colheita
  end

  # GET /recomendacao_colheita/1
  def show
    render json: @recomendacao_colheitum
  end

  # POST /recomendacao_colheita
  def create
    @recomendacao_colheitum = RecomendacaoColheitum.new(recomendacao_colheitum_params)

    if @recomendacao_colheitum.save
      render json: @recomendacao_colheitum, status: :created, location: @recomendacao_colheitum
    else
      render json: @recomendacao_colheitum.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /recomendacao_colheita/1
  def update
    if @recomendacao_colheitum.update(recomendacao_colheitum_params)
      render json: @recomendacao_colheitum
    else
      render json: @recomendacao_colheitum.errors, status: :unprocessable_content
    end
  end

  # DELETE /recomendacao_colheita/1
  def destroy
    @recomendacao_colheitum.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recomendacao_colheitum
      @recomendacao_colheitum = RecomendacaoColheitum.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def recomendacao_colheitum_params
      params.expect(recomendacao_colheitum: [ :lote_id, :data_recomendacao, :expectativa_produtividade, :observacoes, :status ])
    end
end
