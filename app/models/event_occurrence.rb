class EventOccurrence < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :event

  scope :between, lambda {|start_date, end_date| includes(:event).where('"start_time" BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day) }
  scope :on, lambda {|date| between(date, date) }
  scope :not_over, lambda { includes(:event).where("end_time > ?", Time.now) }
  scope :category, lambda {|category| category.nil? ? scoped : includes(:event).where("events.category_id = ?", category.id) }

  scope :upcoming, lambda { between(Date.tomorrow+1, Date.tomorrow+5) }
  scope :tomorrow, lambda { on(Date.tomorrow) }
  scope :today, lambda { on(Date.today).not_over }

  def humanized_start_time
    if started? and !over?
      "now"
    elsif happening_soon?
      "in #{distance_of_time_in_words_to_now(start_time)}"
    else
      start_time.strftime("%A")
    end
  end

  def started?
    Time.now > start_time
  end

  def over?
    Time.now > end_time
  end

  def happening_soon?
    (Time.now+12.hours) > start_time
  end
end