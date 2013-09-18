class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  def index
    if params[:category_id].present?
      @events = Event.where(:category_id => params[:category_id])
      if user_signed_in?
        @events = @events.subscribed(current_user)
      end
    elsif params[:favs].present?
      @events = current_user.flagged_events
    else
      @events = Event.all
    end

    @events = @events.sort_today.is_near(session[:city])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def fav
    @event = Event.find(params[:id])
    current_user.toggle_flag(@event, :fav)

    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def list
    @events = current_user.events.all

    respond_to do |format|
      format.html # list.html.erb
      format.json { render json: @events }
    end
  end

  def new
    @event = current_user.events.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  def edit
    @event = current_user.events.find(params[:id])
  end

  def create
    @event = current_user.events.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to({action: "list"}, notice: 'Venue was successfully created.')}
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event = current_user.events.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to({action: "list"}, notice: 'Venue was successfully updated.')}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to list_path }
      format.json { head :no_content }
    end
  end
end