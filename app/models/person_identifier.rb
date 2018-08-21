class PersonIdentifier < CouchRest::Model::Base

  before_save :set_site_code,:set_district_code,:set_check_digit
  #after_create :insert_update_into_mysql
  #after_save :insert_update_into_mysql
  cattr_accessor :can_assign_den
  cattr_accessor :can_assign_drn

  property :person_record_id, String
  property :identifier_type, String #Entry Number|Registration Number|Death Certificate Number| National ID Number
  property :identifier, String
  property :check_digit
  property :site_code, String
  property :den_sort_value, Integer
  property :drn_sort_value, Integer
  property :district_code, String
  property :creator, String
  property :_rev, String


  timestamps!

  unique_id :identifier

  design do
    view :by__id
    view :by_person_record_id
    view :by_identifier
    view :by_district_code
    view :by_created_at
    view :by_person_record_id_and_identifier_type
    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
    filter :facility_sync, "function(doc,req) {return req.query.site_code == doc.site_code}"
  end

  def person
    person = Person.find(self.person_record_id)
    return person
  end

  def set_creator
    self.creator =  User.current_user.id
  end

  def set_check_digit
    self.check_digit =  PersonIdentifier.calculate_check_digit(self.identifier)
  end

  def set_site_code
    if SETTINGS['site_type'] == "facility"
      self.site_code = self.person.facility_code rescue nil
    else
      self.site_code = nil
    end
  end

  def set_district_code
    self.district_code = self.person.district_code
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = RecordIdentifier.where(person_identifier_id: self.id).first
      sql_record = RecordIdentifier.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["person_identifier_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end
