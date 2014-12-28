require 'stripe'
require 'bluecloth'
module Koudoku
  class Engine < ::Rails::Engine
    isolate_namespace Koudoku
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer 'koudoku.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Koudoku::ApplicationHelper
      end
    end

    initializer 'kouduku.create_plans' do |app|
      if Koudoku.create_plans_in_stripe?
        begin
          ::Plan.all.each do |plan|
            begin
              puts "(kouduku) Found local Plan: #{plan.stripe_id} (#{plan.name})"
              stripe_plan = Stripe::Plan.retrieve(plan.stripe_id)
            rescue Stripe::InvalidRequestError => ire
              if ire.message == "No such plan: #{plan.stripe_id}"
                puts "(kouduku) Creating matching Plan in Stripe: #{plan.stripe_id} (#{plan.name})"
                Stripe::Plan.create(
                  :amount => plan.price,
                  :interval => plan.interval,
                  :name => plan.name,
                  :currency => 'usd',
                  :id => plan.stripe_id
                )
              end
            end
          end
        rescue NameError, ActiveRecord::StatementInvalid
          # ignore: Plan model is not defined yet (migration might not have run)
        end
      end
    end

  end
end
