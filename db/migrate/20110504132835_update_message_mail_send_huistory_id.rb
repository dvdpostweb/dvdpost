class UpdateMessageMailSendHuistoryId < ActiveRecord::Migration
  def self.up
    add_column :message_tickets, :mail_history_id, :integer
    add_index :message_tickets, :mail_history_id
  end

  def self.down
    remove_column :message_tickets, :mail_history_id
  end
end
