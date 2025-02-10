class AdMinBalancetoBankAccount < ActiveRecord::Migration[8.0]
  def change
    add_column :bank_accounts, :min_balance, :integer, default: 0
  end
end
