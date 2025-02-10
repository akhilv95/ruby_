class BankAccountsController < ApplicationController
  def index
    @bank_accounts=BankAccount.all
  end

  def invest
    
  end
end
