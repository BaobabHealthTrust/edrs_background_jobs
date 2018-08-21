require 'couchrest_model'

class HealthFacility < CouchRest::Model::Base
 
  property :district_id,String
  property :facility_code, String
  property :name, String
  property :zone,String
  property :facility_type, String
  property :f_type, String
  property :latitude,String
  property :longitude,String
  
  timestamps!
 
  design do
      view :by__id
      view :by_name
  end
  
end
