class Plan < ActiveRecord::Base

  include Koudoku::Plan
  belongs_to :customer
  belongs_to :coupon
  has_many :subscriptions

  monetize :price_cents

end
