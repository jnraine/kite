require 'spec_helper'

describe Event do
  let(:event) do
    Event.new.tap do |e|
      e.title = "Brian's party"
      e.cost = 0
      e.category_id = 1
      e.venue_id = 1
    end
  end

  it "has occurs on different days" do
    event = Event.new.tap do |e|
      e.title = "Brian's party"
      e.schedule = IceCube::Schedule.new(Time.parse("7pm"), duration: 3.hours)
    end
  end

  describe "#schedule" do
    it "returns a default schedule when schedule_hash is nil" do
      event = Event.new
      event.should_receive(:default_schedule).and_return(:default_schedule)
      event.schedule.should == :default_schedule
    end

    it "returns a schedule object" do
      Event.new.schedule.should respond_to(:occurrences)
    end

    it "is serialized to the schedule_hash upon update save" do
      schedule = IceCube::Schedule.new(Date.tomorrow)
      event.schedule = schedule
      event.save
      event.schedule_hash.should == schedule.to_hash
    end

    it "is serialized to the schedule_hash upon create save" do
      isolated_schedule = IceCube::Schedule.new(Date.tomorrow, duration: 1.hour)
      event = Event.new.tap {|e| e.cost = 0; e.category_id = 1; e.venue_id = 1; e.title = "foo" }
      [isolated_schedule, event.schedule].each do |schedule|
        schedule.add_recurrence_rule(IceCube::Rule.daily.until(Date.today + 1.year))
      end
      event.save
      event.schedule_hash.should == isolated_schedule.to_hash
    end

    it "can be manipulated as an object" do
      event.schedule.duration = 1234.0
      event.save
      event.reload
      event.schedule.duration.should == 1234.0
    end
  end

  it "delegates occurrence methods to schedule" do
    start_time = Time.now
    end_time = start_time + 1.hour

    event.start_time = start_time
    event.schedule.start_time.should == start_time
    
    event.end_time = end_time
    event.schedule.end_time.should == end_time
  end

  describe "#build_future_occurrences" do
    it "creates occurence records until a given end date" do
      event.save # so we can build occurrences using this ID
      every_day_forever = IceCube::Rule.daily.until(Time.parse("January 1, 2020"))
      event.schedule.add_recurrence_rule(every_day_forever)
      end_date = Date.today + 7.days

      event.build_future_occurrences(until_time: end_date)
      event.occurrences.count.should == event.schedule.occurrences(end_date).count
    end
  end

  describe "querying for all events within a date range" do
    let(:next_monday)       { Date.today.next_week }
    let(:one_year_from_now) { Date.today + 1.year }

    before do
      Event.destroy_all

      Event.new.tap do |e|
        e.title = "Daily event"
        e.start_time = next_monday + 7.hours
        e.end_time = e.start_time + 1.hour
        e.schedule.add_recurrence_rule(IceCube::Rule.daily.until(one_year_from_now))

        e.cost = 0
        e.category_id = 1
        e.venue_id = 1

        e.save!
      end

      Event.new.tap do |e|
        e.title = "Weekly (Tues) event"
        e.start_time = next_monday + 1.day + 7.hours
        e.end_time = e.start_time + 1.hour
        e.schedule.add_recurrence_rule(IceCube::Rule.weekly.until(one_year_from_now))
        
        e.cost = 0
        e.category_id = 1
        e.venue_id = 1

        e.save!
      end

      Event.new.tap do |e|
        e.title = "Weekly (T+Th) event"
        e.start_time = next_monday + 2.day + 7.hours
        e.end_time = e.start_time + 1.hour
        every_tuesday_and_thursday = IceCube::Rule.weekly.day(:tuesday, :thursday).until(one_year_from_now)
        e.schedule.add_recurrence_rule(every_tuesday_and_thursday)
        
        e.cost = 0
        e.category_id = 1
        e.venue_id = 1

        e.save!
      end

      Event.all.map {|e| e.build_future_occurrences(until_time: Date.today + 3.months); e.save }
    end

    it "allows querying for all events on a specific day" do
      events_next_monday = Event.on(next_monday)
      events_next_monday.count.should == 1
      events_next_monday.first.should == Event.where(title: "Daily event").first
      Event.on(next_monday + 1.day).count.should == 2
      Event.on(next_monday + 1.day + 7.day).count.should == 3 # next tuesday + a week
    end
  end

  describe "html form schedule API" do
    describe "#recurrence_type" do
      it "returns :none when not using recurrence" do
        event.recurrence_type.should == :none
      end

      it "returns :daily when using a daily rule" do
        event.schedule.add_recurrence_rule(IceCube::Rule.daily)
        event.recurrence_type.should == :daily
      end

      it "returns :weekly when using a weekly rule" do
        event.schedule.add_recurrence_rule(IceCube::Rule.weekly)
        event.recurrence_type.should == :weekly
      end
    end

    describe "#recurrence_type=" do
      it "forces recurrence_type return value as symbol" do
        event.recurrence_type.should == :none
        event.recurrence_type = "daily"
        event.recurrence_type.should == :daily
      end
    end

    describe "days_of_week=" do
      it "sets recurrence for named days of week" do
        next_tuesday = Chronic.parse("next tuesday")
        next_thursday = Chronic.parse("next thursday")
        event.start_time = Date.today
        event.end_time = Date.today + 1.hour
        event.days_of_week = [:tuesday, :thursday]
        event.occurs_on?(next_tuesday).should be_true
        event.occurs_on?(next_thursday).should be_true
      end

      it "raise error on bad day of week" do
        next_tuesday = Chronic.parse("next tuesday")
        next_thursday = Chronic.parse("next thursday")
        event.start_time = Date.today
        event.end_time = Date.today + 1.hour
        expect { event.days_of_week = [:tuesday, :humpday] }.to raise_error(ArgumentError)
      end
    end

    describe "days_of_week" do
      it "returns the days of week this event occurs on, when repeating weekly" do
        event.start_time = Date.today
        event.end_time = Date.today + 1.hour
        event.days_of_week = [:tuesday, :thursday]
        event.days_of_week.should == [:tuesday, :thursday]
      end
    end
  end

  describe "#remove_scheduled_recurrence" do
    it "removes all recurrence events from schedule" do
      event.schedule.add_recurrence_rule(IceCube::Rule.daily)
      event.schedule.recurrence_rules.should_not be_empty
      event.remove_scheduled_recurrence
      event.schedule.recurrence_rules.should be_empty
    end
  end
end