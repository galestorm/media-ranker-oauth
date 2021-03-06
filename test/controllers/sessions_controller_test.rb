require "test_helper"

describe SessionsController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:dan)

      login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", uid: nil, username: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count
    end
  end
  # describe "login_form" do
  #   # The login form is a static page - no real way to make it fail
  #   it "succeeds" do
  #     get login_path
  #     must_respond_with :success
  #   end
  # end

  # describe "login" do
  #   # This functionality is complex!
  #   # There are definitely interesting cases I haven't covered
  #   # here, but these are the cases I could think of that are
  #   # likely to occur. More test cases will be added as bugs
  #   # are uncovered.
  #   #
  #   # Note also: some more behavior is covered in the upvote tests
  #   # under the works controller, since that's the only place
  #   # where there's an interesting difference between a logged-in
  #   # and not-logged-in user.
  #   it "succeeds for a new user" do
  #     username = "test_user"
  #     # Precondition: no user with this username exists
  #     User.find_by(username: username).must_be_nil
  #
  #     post login_path, params: { username: username }
  #     must_redirect_to root_path
  #   end
  #
  #   it "succeeds for a returning user" do
  #     username = User.first.username
  #     post login_path, params: { username: username }
  #     must_redirect_to root_path
  #   end
  #
  #   it "renders 400 bad_request if the username is blank" do
  #     post login_path, params: { username: "" }
  #     must_respond_with :bad_request
  #   end
  #
  #   it "succeeds if a different user is already logged in" do
  #     username = "user_1"
  #     post login_path, params: { username: username }
  #     must_redirect_to root_path
  #
  #     username = "user_2"
  #     post login_path, params: { username: username }
  #     must_redirect_to root_path
  #   end
  # end

  describe "logout" do
    it "succeeds if the user is logged in" do
      # Gotta be logged in first
      login(users(:dan))
      post logout_path
      must_redirect_to root_path
    end

    it "succeeds if the user is not logged in" do
      post logout_path
      must_redirect_to root_path
    end
  end
end
