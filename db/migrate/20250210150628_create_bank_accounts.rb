class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.integer :balance
      t.boolean :enforce_min_balance
      t.integer :min_balance

      t.timestamps
    end
  end
end
