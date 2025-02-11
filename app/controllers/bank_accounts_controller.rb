class BankAccountsController < ApplicationController
  def index
    @bank_accounts = BankAccount.all
  end

  def invest
    investment_amount = params[:investment_amount].to_i
    accounts = BankAccount.all.map do |account|
      available_balance = account.enforce_min_balance ? account.balance - account.min_balance : account.balance
      { name: account.name, balance: account.balance, available: available_balance }
    end

    allocation = allocate_funds(accounts, investment_amount)

    session[:result] = allocation.empty? ? "NO MATCH" : allocation.map { |alloc| { name: alloc[:name], amount: alloc[:amount] } }
    session[:debug] = flash[:result].inspect
    redirect_to root_path
  end
  private

  def allocate_funds(accounts, amount)
    accounts.sort_by! { |acc| acc[:available] }

    if(match = accounts.find { |acc| acc[:available] == amount })
      return [{ name: match[:name], amount: amount }]
    end

    if(greater_match = accounts.find { |acc| acc[:available] > amount })
      return [{ name: greater_match[:name], amount: amount }]
    end

    selected_accounts = []
    total = 0

    accounts.reverse_each do |acc|
      next if acc[:available] <= 0
      taken = [acc[:available], amount - total].min
      selected_accounts << { name: acc[:name], amount: taken }
      total += taken
      break if total >= amount
    end

    return total == amount ? selected_accounts : []
  end
end
