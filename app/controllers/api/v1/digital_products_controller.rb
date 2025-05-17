module Api
  module V1
    class DigitalProductsController < ApplicationController
      before_action :set_digital_product, only: [ :show, :update, :destroy, :purchase ]
      skip_before_action :authorized, only: [ :index, :show ]
      before_action :admin_authorized, only: [ :create, :update, :destroy ]

      # GET /api/v1/digital_products
      def index
        @digital_products = DigitalProduct.includes(:categories, :attachments)
        render json: @digital_products, include: [ :categories, :attachments ]
      end

      # GET /api/v1/digital_products/:id
      def show
        render json: @digital_product, include: [ :categories, :attachments ]
      end

      # POST /api/v1/digital_products
      def create
        @digital_product = DigitalProduct.new(digital_product_params)
        @digital_product.creator = current_user

        if @digital_product.save
          render json: @digital_product, status: :created, include: [ :categories, :attachments ]
        else
          render json: { errors: @digital_product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/digital_products/:id
      def update
        if @digital_product.update(digital_product_params)
          render json: @digital_product, include: [ :categories, :attachments ]
        else
          render json: { errors: @digital_product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/digital_products/:id
      def destroy
        @digital_product.destroy
        head :no_content
      end

      # POST /api/v1/digital_products/:id/purchase
      def purchase
        # Solo los usuarios autenticados pueden comprar
        begin
          purchase = @digital_product.purchase_by(current_user)
          render json: {
            message: 'Producto digital comprado con u00e9xito',
            purchase: purchase
          }
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_digital_product
        @digital_product = DigitalProduct.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Producto digital no encontrado' }, status: :not_found
      end

      def digital_product_params
        params.require(:digital_product).permit(
          :name, :description, :price, :download_url, :file_size, :file_format,
          category_ids: [], attachments_attributes: [ :id, :file, :_destroy ]
        )
      end
    end
  end
end
