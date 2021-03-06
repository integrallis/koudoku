require 'spec_helper'

describe Koudoku::Plan do
  describe '#is_upgrade_from?' do

    class FakePlan
      attr_accessor :price
      include Koudoku::Plan
    end

    it 'returns true if the price is higher' do
      plan = FakePlan.new
      plan.price = 123.23
      cheaper_plan = FakePlan.new
      cheaper_plan.price = 61.61
      plan.is_upgrade_from?(cheaper_plan).should be_true
    end

    it 'returns true if the price is the same' do
      plan = FakePlan.new
      plan.price = 123.23
      plan.is_upgrade_from?(plan).should be_true
    end

    it 'returns false if the price is the same or higher' do
      plan = FakePlan.new
      plan.price = 61.61
      more_expensive_plan = FakePlan.new
      more_expensive_plan.price = 123.23
      plan.is_upgrade_from?(more_expensive_plan).should be_false
    end

    it 'handles a nil value gracefully' do
      plan = FakePlan.new
      plan.price = 123.23
      cheaper_plan = FakePlan.new
      lambda {
        plan.is_upgrade_from?(cheaper_plan).should be_true
      }.should_not raise_error
    end

    it 'returns whether the plan is a free plan' do
      plan = FakePlan.new
      plan.price = 0.0
      expect(plan.free?).to be_true
    end

  end
end
