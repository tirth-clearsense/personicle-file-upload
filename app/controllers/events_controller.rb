class EventsController < ApplicationController
  before_action :set_event, only: %i[ show update destroy ]

  # GET /events
  def index
    puts ENV['DB_HOST']
    puts "hello"

    @events = Event.all

    render json: @events
  end

  # GET /events/1
  def show
    # render json: @event
    @event = Event.last
    # render json: @event
    render json: EventSerializer.new(@event).serializable_hash[:data][:attributes]
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      # render json: @event, status: :created, location: @event
      render json: EventSerializer.new(@event).serializable_hash[:data][:attributes], status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :location, :poster)
    end
end
