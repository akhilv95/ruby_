class ChangeEnforceMinBalanceToBoolean < ActiveRecord::Migration[8.0]
  def change
    change_column :bank_accounts, :enforce_min_balance, :boolean, using: 'enforce_min_balance::boolean'
  end
end
