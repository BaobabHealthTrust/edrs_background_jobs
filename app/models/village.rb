require 'couchrest_model'

class Village < CouchRest::Model::Base

  property :ta_id, String
  property :name, String
  
  timestamps!

  design do
      view :by__id
  end

end
