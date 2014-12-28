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
      puts "BUNDLER DEFINED ==> #{defined?(::Bundler)}"
      puts "RAKE DEFINED ==> #{defined?(::Rake)}"
      puts "PLAN DEFINED ==> #{defined?(::Plan)}"
      puts "Koudoku.create_plans_in_stripe? ==> #{Koudoku.create_plans_in_stripe?}"

      if Koudoku.create_plans_in_stripe?
        if defined?(::Plan)
          ::Plan.all.each do |plan|
            begin
              puts "PLAN ===> #{plan.inspect}"
              stripe_plan = Stripe::Plan.retrieve(plan.stripe_id)
            rescue Stripe::InvalidRequestError => ire
              puts "#{ire} ==> #{ire.message}"
              if ire.message == "No such plan: #{plan.stripe_id}"
                puts "Ok, creating plan ==> #{plan.stripe_id}"
                Stripe::Plan.create(
                :amount => plan.price.to_i,
                :interval => plan.interval,
                :name => plan.name,
                :currency => 'usd',
                :id => plan.stripe_id
                )
              end
            end
          end
        end
      end
    end

  end
end
