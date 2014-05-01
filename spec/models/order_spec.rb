require 'spec_helper'

describe Spree::Order do
  describe "#in_tax_cloud_exempt_state?" do
    let(:order) { build :order, state: state }
    subject { order.in_tax_cloud_exempt_state? }

    context "when the order is in an exempt state" do
      let(:state) { "address" }

      it { should be_true }
    end

    context "when the order is not in an exempt state" do
      let(:state) { "delivery" }

      it { should be_false }
    end
  end

  describe "#tax_cloud_eligible?" do
    let(:order) { build :order, state: state }
    subject { order.tax_cloud_eligible? }

    context "when the order has a valid shipping address" do
      before do
        allow(order).to receive(:ship_address).and_return(build :address)
      end

      context "when the order is not in an exempt state" do
        let(:state) { "complete" }

        it { should be_true }
      end

      context "when the order is in an exempt state" do
        let(:state) { "cart" }

        it { should be_false }
      end
    end

    context "when the order doesn't have a valid shipping address" do
      before do
        allow(order).to receive(:ship_address).and_return(build :address, state_id: nil)
      end
      let(:state) { "complete" }

      it { should be_false }
    end
  end
end
