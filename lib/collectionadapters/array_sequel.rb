module CollectionAdapters
  class ArraySequel
    def initialize model:, column:
      @model = model
      @col   = column.to_sym
    end

    def << val
      @model.new.set(@col => val).save
    rescue Sequel::UniqueConstraintViolation
      nil
    end

    def count
      @model.count
    end

    def concat other
      other.each {|v| self << v }
    end

    def include? key
      @model[@col => key] != nil
    end

    def shift
      @model.db.transaction do
        if ob = @model.for_update.first
          v  = ob.values[@col]
          return v if ob.delete
          raise Sequel::rollback
        end
      end
      nil
    end
  end
end


