module Whereize
  def self.perform object, model
    object.inject({}) do |hash, (k, v)|
      hash[k.to_s.pluralize.to_sym] = if v.is_a?(Hash)
                                        perform v, model
                                      else
                                        {v.to_s.pluralize.to_sym => {id: model.id}}
                                      end
    end
  end
end
