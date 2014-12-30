module Koudoku::Plan
  extend ActiveSupport::Concern

  def is_upgrade_from?(plan)
    (price || 0) >= (plan.price || 0)
  end

  def free?
    price == 0.0
  end

end
