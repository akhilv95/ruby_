class BankAccountsController < ApplicationController
  def index
    @bank_accounts = BankAccount.all
    render :index 
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
    if (match = accounts.find { |acc| acc[:available] == amount })
      return [{ name: match[:name], amount: amount }]
    end
  
    if (greater_match = accounts.find { |acc| acc[:available] > amount })
      return [{ name: greater_match[:name], amount: amount }]
    end
  
    selected_accounts = []
    remaining_amount = amount

    accounts.sort_by! { |acc| -acc[:available] }
  
    largest_contributor = accounts.find { |acc| acc[:available] < amount }
    if largest_contributor
      selected_accounts << { name: largest_contributor[:name], amount: largest_contributor[:available] }
      remaining_amount -= largest_contributor[:available]
    end
  
    accounts.sort_by! { |acc| acc[:available] } 
    smallest_match = accounts.find { |acc| acc[:available] >= remaining_amount }
    if smallest_match
      selected_accounts << { name: smallest_match[:name], amount: remaining_amount }
     
      return selected_accounts
    end
  
    accounts.each do |acc|
      break if remaining_amount <= 0  
  
      deduction = [acc[:available], remaining_amount].min  
      selected_accounts << { name: acc[:name], amount: deduction }
      remaining_amount -= deduction  
      break if remaining_amount == 0  
    end
  
    if remaining_amount == 0
      return selected_accounts
    else
      return []
    end
  end
  
end

