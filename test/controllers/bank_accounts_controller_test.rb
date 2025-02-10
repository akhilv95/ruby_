require "test_helper"

class BankAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bank_accounts_index_url
    assert_response :success
  end

  test "should get invest" do
    get bank_accounts_invest_url
    assert_response :success
  end
end
