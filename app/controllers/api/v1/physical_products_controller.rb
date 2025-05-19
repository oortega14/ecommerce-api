module Api
  module V1
    class PhysicalProductsController < ApplicationController
      before_action :set_physical_product, only: [ :show, :update, :destroy, :purchase, :shipping_cost ]
      before_action :authenticate_admin, only: [ :create, :update, :destroy ]

      # GET /api/v1/physical_products
      def index
        physical_products = PhysicalProduct.includes(:categories, :attachments)
        render_with(physical_products, context: { view: params[:view] })
      end

      # GET /api/v1/physical_products/:id
      def show
        render_with(@physical_product, context: { view: params[:view] })
      end

      # POST /api/v1/physical_products
      def create
        physical_product = PhysicalProduct.new(physical_product_params)
        physical_product.creator = current_user

        render_with(physical_product)
      end

      # PUT /api/v1/physical_products/:id
      def update
        @physical_product.update(physical_product_params)
        render_with(@physical_product)
      end

      # DELETE /api/v1/physical_products/:id
      def destroy
        render_with(@physical_product)
      end

      # POST /api/v1/physical_products/:id/purchase
      def purchase
        begin
          quantity = params[:quantity].to_i || 1
          purchase = @physical_product.purchase_by(current_user, quantity)
          render json: {
            message: 'Physical product purchased successfully',
            purchase: purchase
          }
        rescue StandardError => e
          raise ApiExceptions::BaseException.new(:CANNOT_PURCHASE, [], { error: e.message })
        end
      end

      # GET /api/v1/physical_products/:id/shipping_cost
      def shipping_cost
        render json: { shipping_cost: @physical_product.shipping_cost.to_f }
      end

      # GET /api/v1/physical_products/:id/audits
      def audits
        physical_product = PhysicalProduct.includes(audits: :user).find(params[:id])
        render json: physical_product.audits.map { |audit|
          {
            action: audit.action,
            user: audit.user&.email,
            changes: audit.audited_changes,
            created_at: audit.created_at
          }
        }
      end

      private

      def set_physical_product
        @physical_product = PhysicalProduct.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
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
