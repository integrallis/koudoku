class Subscription < ActiveRecord::Base
  include Koudoku::Subscription

  belongs_to :customer
  belongs_to :coupon

  monetize :current_price_cents
end
