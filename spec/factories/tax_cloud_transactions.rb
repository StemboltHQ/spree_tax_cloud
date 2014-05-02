FactoryGirl.define do
  factory :tax_cloud_transaction, class: Spree::TaxCloudTransaction do
    message "Some Message"
    order
  end
end
