class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_city

  def set_city
  	unless session[:city].present?
      session[:city] = "Victoria" #request.location.city
    end
  	if params[:city].present?
  		session[:city] = params[:city]
    end
  end
end