class UsersController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        render json: { foo: 'bar' }
      end
    end
  end
end

