require 'spec_helper'

RSpec.feature 'TaxCloud Admin management', type: :feature do
  stub_authorization!

  scenario 'User is able to visit TaxCloud configuration in the admin' do
    visit '/admin'

    click_link 'Settings'
    click_link'TaxCloud Settings'

    expect(page).to have_text 'TaxCloud Settings API Login'
  end
end
