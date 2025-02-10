class BankAccountsController < ApplicationController
  def index
    @bank_accounts=BankAccount.all
  end

  def invest
    investment_amount=params[:investment_amount].to_i
    accounts=BankAccount.all.map do |account|
      available_balance = account.enforce_min_balance ? (account.balance - account.min_balance) : account.balance
      { name:account.name, balance:account.balance, available:available_balance }
  end
  allocation = allocate_funds(accounts,investment_amount)
  if allocation.empty?
    @result= "NO MATCH"
  else
    @result= allocation
  end
  @bank_accounts = BankAccount.all
  render :index

end
private

def allocate_funds(accounts, amount)
  accounts.sort_by! { |acc| acc[:available]}

  match= accounts.find{ |acc| acc[:available] == amount}
  return [{name: match[:name], amount:amount}] if match
  greater_match = accounts.find { |acc| acc[:available] > amount }
  return [{ name: greater_match[:name], amount: amount }] if greater_match

  selected_accounts = []
  total = 0

  accounts.reverse_each do |acc|
    next if acc[:available] <= 0
    taken = [acc[:available], amount - total].min
    selected_accounts << { name: acc[:name], amount: taken }
    total += taken
    break if total >= amount
  end

  return selected_accounts if total == amount
  return [] 
end
end
