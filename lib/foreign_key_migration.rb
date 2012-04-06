# Mixin with ActiveRecord::Migration
module ForeignKeyMigration
  def add_foreign_key(table, column, options={})
    options[:reference_table] ||= reference_name(column)
    options[:name] ||= fk_name(table, column)
    execute "ALTER TABLE #{table} ADD CONSTRAINT #{options[:name]} FOREIGN KEY (#{column}) REFERENCES #{options[:reference_table]}(id)"
  end

  def drop_foreign_key(table, column, options={})
    options[:name] ||= fk_name(table, column)
    case ActiveRecord::Base.connection.adapter_name
    when /mysql/i
      execute "ALTER TABLE #{table} DROP FOREIGN KEY #{options[:name]}"
    else
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{options[:name]}"
    end
  end

  private

  def reference_name(column)
    column.to_s.sub(/_id$/, "").pluralize.to_sym
  end

  def fk_name(table, column)
    "fk_#{table}_#{reference_name(column)}"
  end
end

# Mixin with ActiveRecord::Migration::CommandRecorder
module ForeignKeyCommandRecorder
  def add_foreign_key(*args)
    record(:add_foreign_key, args)
  end

  def drop_foreign_key(*args)
    record(:drop_foreign_key, args)
  end

  private

  def invert_add_foreign_key(args)
    [:drop_foreign_key, args]
  end

  def invert_drop_foreign_key(args)
    [:add_foreign_key, args]
  end
end
