class EventOccurrence < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :event

  scope :between, lambda {|start_date, end_date| includes(:event).where('"start_time" BETWEEN ? AND ?', start_date.beginning_of_day+4.hours, end_date.end_of_day+4.hours) }
  scope :on, lambda {|date|
    raw_sql = '"event_occurrences"."start_time" BETWEEN ? AND ?'
    scope = includes(:event)
    scope.where(raw_sql, date.beginning_of_day+4.hours, date.end_of_day+4.hours)
  }
  scope :not_over, lambda { includes(:event).where("end_time > ?", Time.now) }
  scope :category, lambda {|category| category.nil? ? scoped : includes(:event).where("events.category_id = ?", category.id) }
  scope :only_favorited, lambda {|user|
    return scoped unless user
    includes(:event).where("events.id" => user.favourite_events.map(&:id))
  }

  scope :only_subscribed, lambda { |user|
    if user.flagged_hosts.blank?
      scoped
    else
      where("host_id not in ?", user.flagged_hosts) #filter unsubscribed hosts from events
    end
  }

  # Offset date for early morning hours
  scope :upcoming, lambda { 
    difference = Time.now.hour < 4 ? 0 : 1
    between(Date.tomorrow+difference.day, Date.tomorrow+(4+difference).days) 
  }
  scope :tomorrow, lambda {
    difference = Time.now.hour < 4 ? 0 : 1
    on(Date.today+difference.day)
  }
  scope :today, lambda {
    difference = Time.now.hour < 4 ? 0 : 1
    on(Date.yesterday+difference.day).not_over
  }

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