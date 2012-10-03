# Mixin with ActiveRecord::Base
module ColumnMethods
  def q_column column
    lambda { "#{self.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name column.to_s}" }.call
  end

  def star
    lambda { "#{self.quoted_table_name}.*" }.call
  end

  def all_columns
    lambda { self.column_names.collect {|cn| self.q_column(cn) }.join(', ') }.call
  end
end