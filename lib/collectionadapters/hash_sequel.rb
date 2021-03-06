
module CollectionAdapters
  # Takes a Sequel model
  # and provides +#[]+ and +#[]=+
  # using Sequels API.
  #
  # Values are converted silently to String's 
  #
  # NOTE: You need to require 'sequel'
  # yourself; this is to allow you to
  # optionally also use this adapter
  # with other classes that provide the
  # same API.
  #
  class HashSequel
    def initialize(model:, keycolumn:, valuecolumn:)
      @model  = model
      @k = keycolumn.to_sym
      @v = valuecolumn.to_sym
    end

    def []= (key, value)
      key = key.to_s
      (@model.first(@k => key) || @model.new).set(@k => key, @v => value).save
      value
    end

    def [] (key)
      r = @model[@k => key.to_s]
      r ? r.values[@v] : nil
    end

    def delete(key)
      if ob = @model.first(@k => key.to_s)
        ob.delete
        ob.values[@v]
      else
        nil
      end
    end
  end
end
