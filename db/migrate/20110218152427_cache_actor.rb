class CacheActor < ActiveRecord::Migration
  def self.up
      add_column :actors, :cached_slug, :string
      add_index  :actors, :cached_slug, :unique => true
    end

    def self.down
      remove_column :actors, :cached_slug
    end
end
