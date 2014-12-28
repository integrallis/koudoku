require 'spec_helper'

describe Koudoku::WebhooksController do

  before do

    # disable any interaction with stripe for these tests.
    Subscription.any_instance.stub(:processing!).and_return(true)

  end

  describe 'when a valid subscription exists' do
    routes { Koudoku::Engine.routes }

    before do
      # here is the corresponding customer in our database.
      @customer = Customer.create(email: 'andrew.culver@gmail.com')
      @subscription = Subscription.create(customer_id: @customer.id, stripe_id: 'customer-id')
      # make sure they get this exact instance.
      Subscription.stub('find_by_stripe_id').and_return(@subscription)
    end
    describe "invoice.payment_succeeded" do
      describe "POST create" do
        it 'calls payment_succeeded for the subscription' do
          @subscription.should_receive(:payment_succeeded).once
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('invoice.payment_succeeded', total: '1234', customer: @subscription.stripe_id)
        end
        it 'returns 200' do
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('invoice.payment_succeeded', total: '1234', customer: @subscription.stripe_id)
          response.code.should eq("200")
        end
      end
    end
    describe "charge.failed" do
      describe "POST create" do
        it 'calls charge_failed for the subscription' do
          @subscription.should_receive(:charge_failed).once
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('charge.failed', customer: @subscription.stripe_id)
        end
        it 'returns 200' do
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('charge.failed', customer: @subscription.stripe_id)
          response.code.should eq("200")
        end
      end
    end
    describe "charge.dispute.created" do
      describe "POST create" do
        it 'calls charge_disputed for the subscription' do
          @subscription.should_receive(:charge_disputed).once
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('charge.dispute.created', customer: @subscription.stripe_id)
        end
        it 'returns 200' do
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('charge.dispute.created', customer: @subscription.stripe_id)
          response.code.should eq("200")
        end
      end
    end
  end



  describe "everything else" do
    routes { Koudoku::Engine.routes }

    describe "POST create" do
      it 'returns an error if the subscription can not be found' do
        expect {
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('invoice.payment_succeeded', total: '1234', customer: 'some-random-id')
        }.to raise_error
      end

      it "should raise an error for invalid api keys" do
        expect {
          raw_post :create, {api_key: 'not-the-api-key'}, webhooks_json('resource.something_else', total: '1234')
        }.to raise_error
      end

      it "should not raise an error for valid api keys" do
        expect {
          raw_post :create, {api_key: Koudoku.webhooks_api_key}, webhooks_json('resource.something_else', total: '1234')
        }.to_not raise_error
      end
    end
  end
end
