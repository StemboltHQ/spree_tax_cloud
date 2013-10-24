Spree::Order.class_eval do

  has_one :tax_cloud_transaction

  after_update :update_tax

  self.state_machine.after_transition :to => :payment, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?
  self.state_machine.after_transition :to => :complete, :do => :capture_tax_cloud, :if => :tax_cloud_eligible?

  def tax_cloud_eligible?
    ship_address.try(:state_id?)
  end

  def update_tax
    return unless self.total_changed?
    lookup_tax_cloud
  end

  def lookup_tax_cloud
    return unless ship_address.present?

    if tax_cloud_transaction.nil?
      create_tax_cloud_transaction
    end

    tax_cloud_transaction.lookup
    tax_cloud_adjustment
  end

  def tax_cloud_adjustment
    adjustment = adjustments.where(originator_type: tax_cloud_transaction.class, originator_id: tax_cloud_transaction.id).first_or_initialize

    adjustment.source = self
    adjustment.label = 'Tax'
    adjustment.mandatory = true
    adjustment.eligible = true
    adjustment.amount = tax_cloud_transaction.amount

    adjustment.save!
  end

  def promotions_total
    adjustments.eligible.promotion.map(&:amount).sum.abs
  end

  def capture_tax_cloud
    return unless tax_cloud_transaction
    tax_cloud_transaction.capture
  end
end
