class VenuesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def index
    @venues = current_user.venues #only show the user's venues

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  def show
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue }
    end
  end

  def new
    @url_location = :back
    @venue = current_user.venues.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  def edit
    @url_location = venues_path
    @venue = current_user.venues.find(params[:id])
  end

  def create
    @venue = current_user.venues.new(params[:venue])

    respond_to do |format|
      if @venue.save
        format.html { redirect_to({action: "index"}, notice: "New venue? I'll have to check it out.")}
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @venue = current_user.venues.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to({action: "index"}, notice: 'Cool. Got it.')}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @venue = current_user.venues.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :no_content }
    end
  end
end
