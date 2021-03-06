require 'spec_helper'

describe User do
  describe "flagging" do
    let(:event) do
      Event.new.tap do |e|
        e.title = "Brian's party"
        e.cost = 0
        e.category_id = 1
        e.venue_id = 1
        e.save!
      end
    end

    let(:venue) do
      Venue.new.tap do |v|
        v.name = "Commodore Ballroom"
        v.user_id = 1
        v.address = "123 Granville St."
        v.save!
      end
    end

    let(:user) do
      User.new.tap do |u|
        u.email = "bholt@mailinator.com"
        u.password = "password"
        u.save!
      end
    end
  end
end