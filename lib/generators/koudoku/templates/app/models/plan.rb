class Plan < ActiveRecord::Base
  has_many :subscriptions

  include Koudoku::Plan

  belongs_to :<%= subscription_owner_model %>
  belongs_to :coupon

  monetize :price_cents
end
