require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  private

  def sign_in_as(user, password: "password")
    visit login_path
    within ".session-form" do
      fill_in "Email", with: user.email
      fill_in "Password", with: password
      click_on "Log in"
    end
  end
end
