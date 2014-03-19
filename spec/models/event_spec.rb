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
      schedule.start_time = Time.now
      schedule.end_time = Time.now + 1.hour
      event.schedule = schedule
      event.save!
      event.schedule_hash.should == schedule.to_hash
    end

    it "is serialized to the schedule_hash upon create save" do
      isolated_schedule = Event.new.default_schedule
      event = Event.new.tap do |e| 
        e.cost = 0
        e.category_id = 1
        e.venue_id = 1
        e.title = "foo"
        e.repeat_until = "2020-01-01"
      end

      [isolated_schedule, event.schedule].each do |schedule|
        schedule.add_recurrence_rule(IceCube::Rule.daily.until(Date.today + 1.year))
      end
      event.save!
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
    it "builds occurence records until a given end date" do
      event.save
      
      every_day_forever = IceCube::Rule.daily.until(Time.parse("January 1, 2020"))
      event.schedule.add_recurrence_rule(every_day_forever)
      
      seven_days_from_now = Date.today + 7.days

      event.build_future_occurrences(until_time: seven_days_from_now)
      event.occurrences.to_a.count.should == event.schedule.occurrences(seven_days_from_now).count
    end

    it "only creates one occurrence for a non-repeating event" do
      event.occurrences.length.should == 0
      event.save
      event.occurrences.length.should == 1
      event.build_future_occurrences
      event.occurrences.length.should == 1
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
        e.repeat_until = "2020-01-01"

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
        e.repeat_until = "2020-01-01"

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
        e.repeat_until = "2020-01-01"

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

  # describe "html form schedule API" do
  #   describe "#recurrence_type" do
  #     it "returns :none when not using recurrence" do
  #       event.recurrence_type.should == :none
  #     end

  #     it "returns :daily when using a daily rule" do
  #       event.schedule.add_recurrence_rule(IceCube::Rule.daily)
  #       event.recurrence_type.should == :daily
  #     end

  #     it "returns :weekly when using a weekly rule" do
  #       event.schedule.add_recurrence_rule(IceCube::Rule.weekly)
  #       event.recurrence_type.should == :weekly
  #     end
  #   end

  #   describe "#recurrence_type=" do
  #     it "forces recurrence_type return value as symbol" do
  #       event.recurrence_type.should == :none
  #       event.recurrence_type = "daily"
  #       event.recurrence_type.should == :daily
  #     end
  #   end

  #   describe "days_of_week=" do
  #     it "sets recurrence for named days of week" do
  #       next_tuesday = Chronic.parse("next tuesday")
  #       next_thursday = Chronic.parse("next thursday")
  #       event.start_time = Date.today
  #       event.end_time = Date.today + 1.hour
  #       event.days_of_week = [:tuesday, :thursday]
  #       event.occurs_on?(next_tuesday).should be_true
  #       event.occurs_on?(next_thursday).should be_true
  #     end

  #     it "raise error on bad day of week" do
  #       next_tuesday = Chronic.parse("next tuesday")
  #       next_thursday = Chronic.parse("next thursday")
  #       event.start_time = Date.today
  #       event.end_time = Date.today + 1.hour
  #       expect { event.days_of_week = [:tuesday, :humpday] }.to raise_error(ArgumentError)
  #     end
  #   end

  #   describe "days_of_week" do
  #     it "returns the days of week this event occurs on, when repeating weekly" do
  #       event.start_time = Date.today
  #       event.end_time = Date.today + 1.hour
  #       event.days_of_week = [:tuesday, :thursday]
  #       event.days_of_week.should == [:tuesday, :thursday]
  #     end
  #   end
  # end

  describe "#remove_scheduled_recurrence" do
    it "removes all recurrence events from schedule" do
      event.schedule.add_recurrence_rule(IceCube::Rule.daily)
      event.schedule.recurrence_rules.should_not be_empty
      event.remove_scheduled_recurrence
      event.schedule.recurrence_rules.should be_empty
    end
  end

  describe "occurrence generation" do
    it "generates occurrences after new record is saved" do
      event = Event.new.tap do |e|
        e.title = "Brian's birthday"
        e.cost = "Free"
        e.start_time = Time.now + 1.hour
        e.details = "This is a party"
        e.venue_id = 1
        e.category_id = 1
      end

      event.occurrences.should be_empty
      event.save!
      event.occurrences.should_not be_empty
    end

    it "generates occurrences after the schedule has been changed" do
      event = Event.new.tap do |e|
        e.title = "Brian's birthday"
        e.cost = "Free"
        e.details = "This is a party"
        e.venue_id = 1
        e.category_id = 1
        e.save!
      end

      event.occurrences.length.should == 1
      event.repeat = :daily
      event.repeat_until = "2020-01-01"
      event.save!
      event.occurrences.length.should > 1
    end
  end

  describe "repeating API" do
    it "allows repeating daily" do
      event.repeat = :daily
      event.build_future_occurrences(until_time: Date.today + 7.days).count.should == 7
    end

    it "allows repeating weekly on a specific day" do
      event.repeat = :weekly
      event.build_future_occurrences(until_time: Date.today + 14.days).count.should == 2
    end

    it "returns the appropriate value" do
      event.repeat.should be_nil
      event.repeat_daily
      event.repeat.should == :daily
      event.repeat_weekly
      event.repeat.should == :weekly
    end
  end

  describe "#upcoming_dates" do
    before do
      Timecop.travel(Time.parse("January 1, 2000"))
    end

    after do
      Timecop.return
    end

    it "returns the next 7 dates in a readable way" do
      event.repeat = :daily
      event.repeat_until = "2020-01-01"
      event.save!
      event.upcoming_dates(7).should == "January 1, 2, 3, 4, 5, 6, 7"
      event.repeat = :weekly
      event.save!
      event.upcoming_dates(7).should == "January 1, 8, 15, 22, 29, February 5, 12"
    end
  end

  describe "#repeat_until" do
    let(:next_month) { Time.now + 30.days }

    it "stores this value in the model (after coercing it to end of day)" do
      event.repeat_until = next_month
      event.save
      event.reload
      event.repeat_until.to_s.should == next_month.end_of_day.to_s
    end

    it "dumps this value to the schedule when set before repeat" do
      event.repeat_until = next_month
      event.repeat = :daily
      event.recurrence_rule.to_hash.fetch(:until).fetch(:time).should_not == nil
      event.repeat = :weekly
      event.recurrence_rule.to_hash.fetch(:until).fetch(:time).should_not == nil
    end

    it "dumps this value to the schedule when set after repeat" do
      event.repeat = :daily
      event.repeat_until = next_month.to_s
      event.recurrence_rule.to_hash.fetch(:until).fetch(:time).should == next_month.end_of_day.utc
    end
  end

  describe ".on" do
    before { Timecop.freeze(Time.parse("2014-01-01 at 7pm")) }
    after  { Timecop.return }

    def event(start_time: Time.now, end_time: Time.now + 1.hour)
      Event.new.tap do |e|
        e.start_time = start_time
        e.end_time = end_time
        e.title = "Foo"
        e.cost = "1"
        e.venue_id = 1
        e.category_id = 1
        e.save!
      end
    end

    it "returns events that start on given day from 12am to 4am the following day" do
      pending "Change from brian modified behaviour. Not sure of intentded behaviour so I can't fix this test."
      seven_pm_event = event(start_time: Time.parse("2014-01-01 at 7pm"), end_time: Time.parse("2014-01-01 at 8pm"))
      two_am_event   = event(start_time: Time.parse("2014-01-02 at 2am"), end_time: Time.parse("2014-01-02 at 4am"))

      Event.on(Time.parse("2014-01-01")).should == [seven_pm_event, two_am_event]
    end

    it "returns events that end on given day from 12am to 4am the following day" do
      pending "Change from brian modified behaviour. Not sure if intentional so leaving test."
      new_years_eve_event = event(start_time: Time.parse("2013-12-31 at 7pm"), end_time: Time.parse("2014-01-01 at 3am"))
      Event.on(Time.parse("2014-01-01")).should == [new_years_eve_event]
    end
  end

  describe "#weekdays=" do
    before do
      Timecop.travel(Time.parse("January 1, 2000"))
    end

    after do
      Timecop.return
    end

    it "sets weekdays this event occurs on" do
      example_event = event
      example_event.repeat = :weekly
      example_event.repeat_until = Time.now + 30.days
      example_event.weekdays = [0, 1, 2] # Mon, Tue, Wed
      example_event.save!
      expect(example_event.upcoming_dates(5)).to eq("January 3, 4, 5, 10, 11")
    end
  end

  describe "#weekdays" do
    it "returns an array of weekday indexes" do
      example_event = event
      example_event.repeat = :weekly
      example_event.repeat_until = Time.now + 30.days
      example_event.weekdays = [0, 1, 2] # Mon, Tue, Wed
      expect(example_event.weekdays).to eq([0,1,2])
    end

    it "returns an empty array when the recurrence_rule is nil" do
      example_event = event
      example_event.should_receive(:recurrence_rule).and_return(nil)
      expect(example_event.weekdays).to eq([])
    end

    it "returns an empty array when the weekdays are not set in the recurrence_rule" do
      example_event = event
      example_event.repeat = :weekly
      example_event.repeat_until = Time.now + 30.days
      example_event.save! # recurrence rule is created
      expect(example_event.weekdays).to eq([])
    end
  end

  describe ".convert_weekday_indexes_to_symbols" do
    it "takes indexes (starts with monday) and converts to weekday symbols" do
      weekday_symbols = event.convert_weekday_indexes_to_symbols([0, 1, 2, 3, 4, 5, 6])
      expect(weekday_symbols).to eq([:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday])
      weekday_symbols = event.convert_weekday_indexes_to_symbols([0, 3, 4])
      expect(weekday_symbols).to eq([:monday, :thursday, :friday])
    end

    it "only converts number-looking things" do
      weekday_symbols = event.convert_weekday_indexes_to_symbols([:monday, :tuesday])
      expect(weekday_symbols).to eq([:monday, :tuesday])
    end

    it "complains when you give it something silly" do
      expect {
        event.convert_weekday_indexes_to_symbols(["pants"])
      }.to raise_error(ArgumentError)
    end

    it "returns an empty array when you give it nil" do
      expect(event.convert_weekday_indexes_to_symbols(nil)).to eq([])
    end
  end
end