module Api
  module V1
    class PhysicalProductsController < ApplicationController
      before_action :set_physical_product, only: [ :show, :update, :destroy, :purchase, :shipping_cost ]
      skip_before_action :authorized, only: [ :index, :show, :shipping_cost ]
      before_action :admin_authorized, only: [ :create, :update, :destroy ]

      # GET /api/v1/physical_products
      def index
        @physical_products = PhysicalProduct.includes(:categories, :attachments)
        render json: @physical_products, include: [ :categories, :attachments ]
      end

      # GET /api/v1/physical_products/:id
      def show
        render json: @physical_product, include: [ :categories, :attachments ]
      end

      # POST /api/v1/physical_products
      def create
        @physical_product = PhysicalProduct.new(physical_product_params)
        @physical_product.creator = current_user

        if @physical_product.save
          render json: @physical_product, status: :created, include: [ :categories, :attachments ]
        else
          render json: { errors: @physical_product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/physical_products/:id
      def update
        if @physical_product.update(physical_product_params)
          render json: @physical_product, include: [ :categories, :attachments ]
        else
          render json: { errors: @physical_product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/physical_products/:id
      def destroy
        @physical_product.destroy
        head :no_content
      end

      # POST /api/v1/physical_products/:id/purchase
      def purchase
        # Solo los usuarios autenticados pueden comprar
        begin
          quantity = params[:quantity].to_i || 1
          purchase = @physical_product.purchase_by(current_user, quantity)
          render json: {
            message: 'Producto físico comprado con éxito',
            purchase: purchase
          }
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/physical_products/:id/shipping_cost
      def shipping_cost
        # Asegurar que el costo de envío se devuelva como un número, no como cadena
        render json: { shipping_cost: @physical_product.shipping_cost.to_f }
      end

      private

      def set_physical_product
        @physical_product = PhysicalProduct.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Producto físico no encontrado' }, status: :not_found
      end

      def physical_product_params
        params.require(:physical_product).permit(
          :name, :description, :price, :stock, :weight, :dimensions,
          category_ids: [], attachments_attributes: [ :id, :file, :_destroy ]
        )
      end
    end
  end
end
