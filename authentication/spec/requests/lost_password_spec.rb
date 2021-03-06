require "spec_helper"

module Refinery
  module Users
    describe "password recovery" do
      let!(:user) { Factory(:refinery_user, :email => "refinery@refinerycms.com") }

      it "asks user to specify email address" do
        visit new_refinery_user_session_url
        click_link "I forgot my password"
        has_content?("Please enter the email address for your account.").should be_true
      end

      context "when existing email specified" do
        it "shows success message" do
          visit new_refinery_user_password_url
          fill_in "refinery_user_email", :with => user.email
          click_button "Reset password"
          has_content?("An email has been sent to you with a link to reset your password.").should be_true
        end
      end

      context "when non-existing email specified" do
        it "shows failure message" do
          visit new_refinery_user_password_url
          fill_in "refinery_user_email", :with => "none@refinerycms.com"
          click_button "Reset password"
          has_content?("Sorry, 'none@refinerycms.com' isn't associated with any accounts.").should be_true
          has_content?("Are you sure you typed the correct email address?").should be_true
        end
      end

      context "when good reset code" do
        before do
          user.reset_password_token = "refinerycms"
          user.save
        end

        it "allows to change password" do
          visit edit_refinery_user_password_url(:reset_password_token => user.reset_password_token)
          page.should have_content("Pick a new password for #{user.email}")

          fill_in "refinery_user_password", :with => "123456"
          fill_in "refinery_user_password_confirmation", :with => "123456"
          click_button "Reset password"

          page.should have_content("Password reset successfully for '#{user.email}'")
        end
      end

      context "when invalid reset code" do
        it "shows error message" do
          visit edit_refinery_user_password_url(:reset_password_token => "hmmm")
          page.should have_content("We're sorry, but this reset code has expired or is invalid.")
        end
      end
    end
  end
end
