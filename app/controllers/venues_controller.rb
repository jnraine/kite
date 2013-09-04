class VenuesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def index
    @venues = current_user.venues.all

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
    @venue = current_user.venues.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  def edit
    @venue = current_user.venues.find(params[:id])
  end

  def create
    @venue = current_user.venues.new(params[:venue])

    respond_to do |format|
      if @venue.save
        format.html { redirect_to({action: "index"}, notice: 'Venue was successfully created.')}
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
        format.html { redirect_to({action: "index"}, notice: 'Venue was successfully updated.')}
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
