class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_city

  def set_city
  	unless session[:city].present?
      session[:city] = "Victoria" #request.location.city #get the user location by default
    end
  	if params[:city].present?
  		session[:city] = params[:city] #change to user specificied location
    end
  end

  # Used to make the Create flash message read more human
  def create_flash_message
    case rand(1..3)
      when 1
        "Fun!"
      when 2
        "This looks awesome."
      when 3
        "That looks good."
      else
        "That looks good."
    end
  end

  # Used to make the Update flash message read more human
  def update_flash_message
    case rand(1..2)
      when 1
        "Done!"
      when 2
        "No problem."
      when 3
        "Cool. Got it."
      else
        "Cool. Got it."
    end
  end   
end