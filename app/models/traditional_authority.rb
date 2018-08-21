require 'couchrest_model'

class TraditionalAuthority < CouchRest::Model::Base
  property :district_id, String
  property :name, String
  
  timestamps!
 
  design do
      view :by__id
  end
  
end
