require 'spec_helper'

describe Spree::TaxCloudTransaction do
  describe "#update_adjustment", vcr: true do
    let!(:transaction) { create :tax_cloud_transaction }
    let(:order) { transaction.order }
    let!(:variant) { create :variant, sku: "12345" }
    let(:adjustment_double) { double('Spree::Adjustment') }

     before do
       create(:line_item, variant: variant, order: transaction.order)
       order.update_attributes(ship_address: create(:address, zipcode: "35004"))
       order.reload.update!
       transaction.lookup
       transaction.cart_items.first.update_attributes({amount: 2}, without_protection: true)
       transaction.reload
     end

     subject { transaction.update_adjustment(adjustment_double, "whatever") }

     context "when the order has an item total > 0" do
       before do
         order.update_column(:item_total, BigDecimal.new(10))
       end

       it "sets the tax to two dollars" do
         expect(adjustment_double).to receive(:update_attribute_without_callbacks).
           with(:amount, BigDecimal.new(2))
         subject
       end
     end

     context "when the orders' item total is 0" do
       before do
         order.update_column(:item_total, BigDecimal.new(0))
       end

       it "sets the tax to zero dollars, as you cannot tax nothing" do
         expect(adjustment_double).to receive(:update_attribute_without_callbacks).
           with(:amount, BigDecimal.new(0))
         subject
       end
     end
  end
end
