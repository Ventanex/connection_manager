require 'active_record/querying.rb'
module ConnectionManager
  module Using
    module ClassMethods
      def >=(compare)
        return self >= compare.klass if compare.is_a?(ConnectionManager::Using::Proxy)
        super(compare)
      end

      def ==(compare)
        return self == compare.klass if compare.is_a?(ConnectionManager::Using::Proxy)
        super(compare)
      end

      def !=(compare)
        return self != compare.klass if compare.is_a?(ConnectionManager::Using::Proxy)
        super(compare)
      end
    end

    class Proxy
      include ActiveRecord::Querying

      attr_accessor :klass, :connection_class

      def initialize(klass,connection_class)
        @klass = klass  # the @klass from an ActiveRecord::Relation
        @connection_class = (connection_class.is_a?(String) ? connection_class.constantize : connection_class)
        ConnectionManager.logger.debug "Using proxy connection: #{@connection_class.name} for #{@klass.name}" if ConnectionManager.logger
      end

      # Use the connection from the connection class
      def connection
        @connection_class.connection
      end

      # Make sure we return the @klass superclass,
      # which used throughout the query building code in AR
      def superclass
        @klass.superclass
      end

      def >= compare
        return @klass >= compare.klass if compare.is_a?(self.class)
        @klass >= compare
      end

      def == compare
        return @klass == compare.klass if compare.is_a?(self.class)
        @klass == compare
      end

      def != compare
        return @klass != compare.klass if compare.is_a?(self.class)
        @klass != compare
      end

      def descendants
        @klass.descendants
      end

      def subclasses
        @klass.subclasses
      end

      def parent
        @klass.parent
      end

      # Pass all methods to @klass, this ensures objects
      # build from the query are the correct class and
      # any settings in the model like table_name_prefix
      # are used.
      def method_missing(name, *args, &blk)
        @klass.send(name, *args,&blk)
      end

      def respond_to?(method_name, include_private = false)
        @klass.respond_to?(method_name) || super
      end
    end
  end
end
ActiveRecord::Relation.send(:extend, ConnectionManager::Using::ClassMethods)
ActiveRecord::Base.send(:extend, ConnectionManager::Using::ClassMethods)
