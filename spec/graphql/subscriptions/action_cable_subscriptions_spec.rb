# frozen_string_literal: true
require "spec_helper"
require "graphql/subscriptions/action_cable_subscriptions"

describe GraphQL::Subscriptions::ActionCableSubscriptions do
  describe "#handle_streamed_event" do
    it "calls #execute" do
      event = OpenStruct.new
      subscription_id = "subscription_id"
      message = '"message"'
      execute = MiniTest::Mock.new
      execute.expect(:call, nil, ["subscription_id", event, "message"])

      instance = GraphQL::Subscriptions::ActionCableSubscriptions.new(schema: nil)
      instance.stub(:execute, execute) do
        instance.handle_streamed_event(subscription_id, event, [message, nil])
      end

      execute.verify
    end
    
    it "does not call #execute if the scope exclude value matches" do
      scope_exclude_val = "foo"
      event = OpenStruct.new(scope_exclude_val: scope_exclude_val)
      subscription_id = "subscription_id"
      message = '"message"'
      raises_exception = ->(_, __, ___) { raise StandardError.new }

      instance = GraphQL::Subscriptions::ActionCableSubscriptions.new(schema: nil)
      instance.stub(:execute, raises_exception) do
        instance.handle_streamed_event(subscription_id, event, [message, scope_exclude_val])
      end
    end

    it "calls #execute if the scope exclude value does not match" do
      event = OpenStruct.new(scope_exclude_val: "foo")
      subscription_id = "subscription_id"
      message = '"message"'
      execute = MiniTest::Mock.new
      execute.expect(:call, nil, ["subscription_id", event, "message"])

      instance = GraphQL::Subscriptions::ActionCableSubscriptions.new(schema: nil)
      instance.stub(:execute, execute) do
        instance.handle_streamed_event(subscription_id, event, [message, "bar"])
      end

      execute.verify
    end
  end
end
