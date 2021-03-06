require 'spec_helper'

describe EventOccurrence do
  describe "scopes" do
    xit "can pull up all occurrences for a particular category" do

    end
  end

  describe "#humanized_start_time" do
    it "returns relative-to-now time for future events starting in the near future" do
      occurrence = EventOccurrence.new
      occurrence.start_time = Time.now + 1.hour
      occurrence.end_time = Time.now + 2.hour
      occurrence.humanized_start_time.should == "in about 1 hour"
    end

    it "returns 'now' for events already started" do
      occurrence = EventOccurrence.new
      occurrence.start_time = Time.now - 1.hour
      occurrence.end_time = Time.now + 1.hour
      occurrence.humanized_start_time.should == "now"
    end
  end
end
