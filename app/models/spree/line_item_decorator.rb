Spree::LineItem.class_eval do
  after_create :update_order_tax
  after_destroy :update_order_tax

  def update_order_tax
    self.order.lookup_tax_cloud
  end
end
