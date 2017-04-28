require 'rails_helper'

describe 'signing up' do
  context 'a invalid user' do
    it 'does not create the user with no email' do
      visit new_user_registration_url
      fill_in 'user_name', with: 'Foo Bar'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      expect do
        within('.actions') { click_on 'Send request' }
      end.not_to change { User.count }
    end
    it 'does not create the user with no password' do
      visit new_user_registration_url
      fill_in 'user_name', with: 'Foo Bar'
      fill_in 'user_email', with: 'foo@valid.com'
      expect do
        within('.actions') { click_on 'Send request' }
      end.not_to change { User.count }
    end
  end
  context 'a valid user' do
    it 'creates the user' do
      visit new_user_registration_url
      fill_in 'user_name', with: 'Foo Bar'
      fill_in 'user_email', with: 'foo@valid.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      expect do
        within('.actions') { click_on 'Send request' }
      end.to change { User.count }.by 1
    end
  end
  context 'after signup' do
    it 'allows the user to only view scoreboard' do
      user = create :user
      create :participant
      login_as user
      visit root_path
      within 'nav' do
        expect(current_scope).to have_text 'Scoreboard'
        expect(current_scope).not_to have_text 'Maneuver'
        expect(current_scope).not_to have_text 'Circle Check'
        expect(current_scope).not_to have_text 'Quiz'
        expect(current_scope).not_to have_text 'Participants'
        expect(current_scope).not_to have_text 'Vehicles'
        expect(current_scope).not_to have_text 'Roles'
        expect(current_scope).not_to have_text 'Manage Users'
      end
    end
  end
end
