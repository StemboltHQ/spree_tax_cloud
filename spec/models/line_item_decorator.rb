require 'spec_helper'

describe Spree::LineItem do
  describe "#update_order_tax" do
    let(:order) { create :order, state: state, ship_address: create(:address) }
    let(:li) { create :line_item, order: order }

    subject { li.update_order_tax }

    context "when the order is 'tax_cloud_eligible'" do
      let(:state) { "address" }
      it "does not tell the order to lookup the tax cloud" do
        expect(order).to_not receive(:lookup_tax_cloud)
        subject
      end
    end

    context "when the order is not 'tax_cloud_eligible'" do
      let(:state) { "complete" }
      it "tells the order to lookup the tax cloud" do
        expect_any_instance_of(Spree::Order).to receive(:lookup_tax_cloud).exactly(2).times
        subject
      end
    end
  end

  describe "active record callbacks" do
    context "on destroy" do
      let(:li) { create :line_item }
      it "calls update_order_tax" do
        expect(li).to receive(:update_order_tax).once
        li.destroy
      end
    end

    context "on create" do
      let(:li) { build :line_item }
      it "calls update_order_tax" do
        expect(li).to receive(:update_order_tax).once
        li.save!
      end
    end
  end
end
