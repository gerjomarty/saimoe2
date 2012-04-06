module ActiveRecord
  class Migration
    include ForeignKeyMigration

    class CommandRecorder
      include ForeignKeyCommandRecorder
    end
  end

  class Base
    include NullifyBlankAttributes
    extend ColumnMethods
  end
end