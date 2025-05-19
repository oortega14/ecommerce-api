module Api
  module V1
    class DigitalProductsController < ApplicationController
      before_action :set_digital_product, only: [ :show, :update, :destroy, :purchase ]
      before_action :authenticate_admin, only: [ :create, :update, :destroy ]

      # GET /api/v1/digital_products
      def index
        digital_products = DigitalProduct.includes(:categories, :attachments)
        render_with(digital_products, context: { view: view_param })
      end

      # GET /api/v1/digital_products/:id
      def show
        render_with(@digital_product, context: { view: view_param })
      end

      # POST /api/v1/digital_products
      def create
        digital_product = DigitalProduct.new(digital_product_params)
        digital_product.creator = current_user

        render_with(digital_product)
      end

      # PUT /api/v1/digital_products/:id
      def update
        @digital_product.update(digital_product_params)
        render_with(@digital_product)
      end

      # DELETE /api/v1/digital_products/:id
      def destroy
        render_with(@digital_product)
      end

      # POST /api/v1/digital_products/:id/purchase
      def purchase
        begin
          purchase = @digital_product.purchase_by(current_user)
          render json: {
            message: 'Digital product purchased successfully',
            purchase: purchase
          }
        rescue StandardError => e
          raise ApiExceptions::BaseException.new(:CANNOT_PURCHASE, [], { error: e.message })
        end
      end

      private

      def set_digital_product
        @digital_product = DigitalProduct.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
      end

      def digital_product_params
        params.require(:digital_product).permit(
          :name, :description, :price, :download_url, :file_size, :file_format,
          category_ids: [], attachments_attributes: [ :id, :file, :_destroy ]
        )
      end

      def view_param
        params[:view]&.to_sym
      end
    end
  end
end
