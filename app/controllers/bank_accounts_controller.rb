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
    puts "🔹 Requested Investment Amount: #{amount}"
  
    # Sort accounts by available balance (smallest first) to check for exact matches
    accounts.sort_by! { |acc| acc[:available] }
    puts "🔹 Accounts Sorted (Lowest First for Exact Match): #{accounts.inspect}"
  
    #  **Check for an Exact Match First**
    if (match = accounts.find { |acc| acc[:available] == amount })
      puts " Exact Match Found: #{match[:name]} - #{amount}"
      return [{ name: match[:name], amount: amount }]
    end
  
    #  **Check for a Single Account That Can Cover the Amount**
    if (greater_match = accounts.find { |acc| acc[:available] > amount })
      puts " Single Account Found (Greater Balance): #{greater_match[:name]} - #{amount}"
      return [{ name: greater_match[:name], amount: amount }]
    end
  
    #  **Check for Multiple Accounts That Add Up to the Exact Amount**
    puts " No Single Match Found, Trying Multiple Accounts..."
    selected_accounts = []
    remaining_amount = amount
  
    # **Sort in Descending Order to Prioritize the Largest Contribution First**
    accounts.sort_by! { |acc| -acc[:available] }
  
    # **Step 1: Pick the Largest Account That’s Less Than the Amount**
    largest_contributor = accounts.find { |acc| acc[:available] < amount }
    if largest_contributor
      selected_accounts << { name: largest_contributor[:name], amount: largest_contributor[:available] }
      remaining_amount -= largest_contributor[:available]
      puts " Selected Largest Contributor: #{largest_contributor[:name]} - #{largest_contributor[:available]}"
    end
  
    # **Step 2: Find the Smallest Account That Completes the Remaining Amount**
    accounts.sort_by! { |acc| acc[:available] } # Re-sort to find the smallest balance
    smallest_match = accounts.find { |acc| acc[:available] >= remaining_amount }
    if smallest_match
      selected_accounts << { name: smallest_match[:name], amount: remaining_amount }
      puts " Selected Smallest Contributor: #{smallest_match[:name]} - #{remaining_amount}"
      return selected_accounts
    end
  
    # **Step 3: If No Single Smallest Match, Use Multiple Accounts**
    accounts.each do |acc|
      break if remaining_amount <= 0  # Stop once we reach the exact amount
  
      deduction = [acc[:available], remaining_amount].min  # Only take what's needed
      selected_accounts << { name: acc[:name], amount: deduction }
      remaining_amount -= deduction  # Reduce remaining required amount
  
      puts " Deducting #{deduction} from #{acc[:name]}, Remaining: #{remaining_amount}"
  
      break if remaining_amount == 0  # Stop once we reach the exact match
    end
  
    #  **Only Return If We Found an Exact Match**
    if remaining_amount == 0
      puts " Successful Allocation: #{selected_accounts.inspect}"
      return selected_accounts
    else
      puts " No Exact Match Found"
      return []
    end
  end
  
end

