# Mixin with ActiveRecord::Base
module ColumnMethods
  def q_column column
    lambda { "#{self.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name column.to_s}" }.call
  end

  def all_columns
    lambda { self.column_names.collect {|cn| "#{self.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name cn}"}.join(', ') }.call
  end
end