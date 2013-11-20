class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  def index
    if params[:category_id].present?
      @events = Event.categorize(params[:category_id]) #filter events by category
      if user_signed_in?
        if current_user.subscribed #does the user want to see all or subscribed events only?
          @events = @events.subscribed(current_user) #only show subscribed events
        end
      end
    elsif params[:favs].present? #is it the favourite category?
      @events = current_user.flagged_events #show favs
    end
    @upcoming = @events.occurs_between(Date.tomorrow+1, Date.tomorrow+5) #show events up to a week ahead
    @tomorrow = @events.occurs_on(Date.tomorrow) #show events tomorrow
    @events = @events.occurs_on(Date.today).not_over #show today's events that haven't ended
    #.is_near(session[:city]) #filter events by city

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def fav
    @event = Event.find(params[:id])
    current_user.toggle_flag(@event, :fav) #toggle :fav flag via flaggable gem

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
    @event = Event.new
    @event.days.build #allows days to be added to events via nested form
    @event.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  def edit
    @event = current_user.events.find(params[:id])
  end

  def create
    @event = Event.new(params[:event])
    @event.user_id = current_user.id

    respond_to do |format|
      if @event.save
        format.html { redirect_to({action: "list"}, notice: 'Yay! A new event!')}
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
        format.html { redirect_to({action: "list"}, notice: 'Cool. Got it.')}
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