require 'spec_helper'

describe "invalid address during checkout", js: true, vcr: true do
  let!(:product) { create :product }

  before do
    # ensure the transition from address to delivery fails
    allow_any_instance_of(Spree::Order).to receive(:create_proposed_shipments).and_return(false)

    visit spree.products_path
    click_link product.name
    click_button "add-to-cart-button"
    click_button "Checkout"

    fill_in "order_email", :with => "test@example.com"
    click_button "Continue"

    address = "order_bill_address_attributes"
    fill_in "#{address}_firstname", :with => "John"
    fill_in "#{address}_lastname", :with => "Doe"
    fill_in "#{address}_address1", :with => "143 Swan Street"
    fill_in "#{address}_city", :with => "Montgomery"
    select "United States of America", :from => "#{address}_country_id"
    select "Alabama", :from => "#{address}_state_id"
    fill_in "#{address}_zipcode", :with => "12345"
    fill_in "#{address}_phone", :with => "(555) 5555-555"
    click_button "Save and Continue"
    expect(Spree::Order.last.state).to eql("address")
    expect(Spree::Order.last.ship_address).to be
  end

  context "after trying to move to the delivery step and failing" do
    let!(:other_product) { create :product, name: "other prod" }
    it "allows for line items to be removed from the cart" do
      visit spree.cart_path
      click_link 'delete_line_item_1'
      expect(page).to have_content("Your cart is empty")
    end

    it "allows line items to be added to the cart" do
      visit spree.product_path(other_product)
      click_button "add-to-cart-button"
      expect(current_path).to eql(spree.cart_path)
      expect(page).to have_content(other_product.name)
    end
  end
end
