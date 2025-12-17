require "application_system_test_case"
require "securerandom"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector ".user-directory-title", text: "Community"
  end

  test "should create user" do
    visit new_user_url

    fill_in "Email", with: "new_user_#{SecureRandom.hex(4)}@example.com"
    fill_in "Password", with: "secret123"
    fill_in "Confirm Password", with: "secret123"
    fill_in "Name", with: "System Test User"
    fill_in "Bio", with: "This profile was created by a system test."
    click_on "Create User"

    assert_text "User was successfully created."
  end

  test "should update user" do
    sign_in_as(@user)

    visit user_url(@user)
    click_on "Edit profile"

    fill_in "Name", with: "Updated Display Name"
    fill_in "Bio", with: "Updated bio from system test."
    click_on "Update User"

    assert_text "User was successfully updated."
  end

  test "should destroy user" do
    user = User.create!(
      email: "system-delete-#{SecureRandom.hex(3)}@example.com",
      password: "secret123",
      password_confirmation: "secret123",
      name: "Disposable User",
      bio: "Created just for system test deletion."
    )

    sign_in_as(user, password: "secret123")

    visit user_url(user)
    accept_confirm { click_on "Delete account" }

    assert_text "User was successfully destroyed."
  end
end
