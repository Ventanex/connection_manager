module ConnectionManager
  module Core
    # We want to make sure we get the full table name with schema
    def arel_table # :nodoc:
      @arel_table = Arel::Table.new(table_name, arel_engine) unless (@arel_table && (@arel_table.name == self.table_name))
      @arel_table
    end
  end
end
ActiveRecord::Core::ClassMethods.send(:include,ConnectionManager::Core)
