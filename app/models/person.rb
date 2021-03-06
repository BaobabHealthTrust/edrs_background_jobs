class Person < CouchRest::Model::Base

  #use_database "death"

  before_save NameCodes.new("first_name")
  before_save NameCodes.new("last_name")
  before_save NameCodes.new("middle_name")

  before_save NameCodes.new("mother_first_name")
  before_save NameCodes.new("mother_last_name")
  before_save NameCodes.new("mother_middle_name")

  before_save NameCodes.new("father_first_name")
  before_save NameCodes.new("father_last_name")
  before_save NameCodes.new("father_middle_name")

  before_save NameCodes.new("informant_first_name")
  before_save NameCodes.new("informant_last_name")
  before_save NameCodes.new("informant_middle_name")

  #after_initialize :decrypt_data

  #before_save :encrypt_data

  before_save :set_facility_code,:set_district_code
  #after_save :insert_update_into_mysql
  after_create :create_stat #, :insert_update_into_mysql

  cattr_accessor :duplicate
  
  def decrypt_data
    encryptable = ["first_name","last_name",
                   "middle_name","last_name",
                   "mother_first_name","mother_last_name",
                   "mother_middle_name","mother_id_number",
                   "father_id_number","father_first_name",
                   "father_last_name","father_middle_name",
                   "father_id_number","informant_first_name","informant_last_name",
                   "informant_middle_name"]
    (self.attributes || []).each do |attribute|

      next unless encryptable.include? attribute[0] || (attribute[1].length > 20 && attribute[1].match(/\=+/))

      self.send("#{attribute[0]}=", (attribute[1].decrypt rescue attribute[1])) unless attribute[1].blank?
    end
  end
  
  def encrypt_data
    encryptable = ["first_name","last_name",
                   "middle_name","last_name",
                   "mother_first_name","mother_last_name",
                    "mother_middle_name","mother_id_number",
                   "father_id_number","father_first_name",
                   "father_last_name","father_middle_name",
                   "father_id_number","informant_first_name","informant_last_name",
                   "informant_middle_name"]
    (self.attributes || []).each do |attribute|

      next unless encryptable.include? attribute[0] || (attribute[1].length > 20 && attribute[1].match(/\=+/))

      self.send("#{attribute[0]}=", attribute[1].encrypt) unless attribute[1].blank?
    end
  end

  def create_status
    
    if self.duplicate.nil?
      PersonRecordStatus.create({
                                  :person_record_id => self.id.to_s,
                                  :status => "DC ACTIVE",
                                  :district_code =>  self.district_code,
                                  :created_by => User.current_user.id})
    else
      
      change_log = [{:duplicates => self.duplicate.to_s}]

      Audit.create({
                      :record_id  => self.id.to_s,
                      :audit_type => "POTENTIAL DUPLICATE",
                      :reason     => "Record is a potential",
                      :change_log => change_log
      })
      PersonRecordStatus.create({
                                  :person_record_id => self.id.to_s,
                                  :status => "DC POTENTIAL DUPLICATE",
                                  :district_code => self.district_code,
                                  :created_by => User.current_user.id})

      self.duplicate = nil

    end
    
  end

  def create_stat

  end

  #Person methods
  def person_id=(value)
    self['_id']=value.to_s
  end

  def person_id
    self['_id']
  end


  def self.update_state(id, status, audit_status)

    person = Person.find(id)
    raise "Person with ID: #{id} not found".to_s if person.blank?

    status = status
    audit_status = audit_status
    audit_reason = "Admin request"

    user = User.find("admin")
    name = user.first_name + " " + user.last_name

    person.status = status
    person.status_changed_by = name
    person.save

    audit = Audit.new()
    audit["record_id"] = person.id
    audit["audit_type"] = audit_status
    audit["reason"] = audit_reason
    audit.save
  end

  def set_district_code
    unless self.district_code.present?
      self.district_code = SETTINGS["district_code"]
    end 
    if SETTINGS['site_type'] == "remote"
      self.district_code = User.current_user.district_code
    end   
  end

  def set_facility_code
    unless self.facility_code.present?
      if SETTINGS['site_type'] == "dc"
        self.facility_code = nil
      else
         self.facility_code = (SETTINGS['facility_code'] rescue nil)
      end
     
    end 
  end

  def status
    PersonRecordStatus.by_person_recent_status.key(self.id).last.status
  end

  def change_status(nextstatus)
    status = PersonRecordStatus.by_person_recent_status.key(self.id.to_s).last
    status.update_attributes({:voided => true})
    PersonRecordStatus.create({
                        :person_record_id => self.id.to_s,
                        :status => nextstatus,
                        :district_code =>(self.district_code rescue SETTINGS['district_code']),
                        :creator => User.current_user.id})
  end

  #Identifiers
  def den
    return PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id, "DEATH ENTRY NUMBER"]).first.identifier rescue "XXXXXXXX"
  end
  def national_id
    return self.id_number rescue "XXXXXXXX"
  end
  def barcode
      PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id,"Form Barcode"]).first.identifier rescue "XXXXXXXX"
  end
  def drn
      return PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id, "DEATH REGISTRATION NUMBER"]).first.identifier rescue "XXXXXXXX"
  end

  def insert_update_into_mysql
    fields  = self.keys.sort
    sql_record = Record.where(person_id: self.id).first
    sql_record = Record.new if sql_record.blank?
    fields.each do |field|
      next if field == "type"
      next if field == "_rev"
      next if field == "source_id"
      if field =="_id"
          sql_record["person_id"] = self[field]
      else
          sql_record[field] = self[field]
      end

    end
    sql_record.save
  end

  #Person properties
  property :source_id, String
  property :first_name, String
  property :middle_name, String
  property :last_name, String
  property :first_name_code, String
  property :last_name_code, String
  property :middle_name_code, String
  property :id_number, String
  property :gender, String
  property :birthdate, Date
  property :birthdate_estimated, Integer, :default => 0
  property :date_of_death, Date
  property :nationality_id, String
  property :nationality, String
  property :other_nationality, String
  property :place_of_registration, String
  property :place_of_death, String
  property :hospital_of_death_id, String
  property :hospital_of_death, String
  property :other_place_of_death, String
  property :other_place_of_death_village, String
  property :place_of_death_village, String
  property :place_of_death_village_id, String
  property :other_place_of_death_ta, String
  property :place_of_death_ta_id, String
  property :place_of_death_ta, String
  property :place_of_death_district_id, String
  property :place_of_death_district, String
  property :place_of_death_country, String
  property :other_place_of_death_country, String
  property :place_of_death_foreign, String
  property :place_of_death_foreign_state, String #State
  property :place_of_death_foreign_district, String #District
  property :place_of_death_foreign_village, String #Town / Village
  property :place_of_death_foreign_hospital, String
  property :cause_of_death_available, String
  property :autopsy_requested, String, :default => "No"
  property :autopsy_used_for_certification, String, :default => "No"
  property :cause_of_death1, String
  property :icd_10_1, String
  property :other_cause_of_death1, String
  property :onset_death_interval1, String
  property :cause_of_death2, String
  property :icd_10_2, String
  property :other_cause_of_death2, String
  property :onset_death_interval2, String
  property :cause_of_death3, String
  property :icd_10_3, String
  property :other_cause_of_death3, String
  property :onset_death_interval3, String
  property :cause_of_death4, String
  property :icd_10_4, String
  property :other_cause_of_death4, String
  property :onset_death_interval4, String
  property :cause_of_death_conditions, {}
  property :coder, String
  property :coded_at, Time
  property :icd_10_code, String
  property :manner_of_death, String
  property :other_manner_of_death, String
  property :death_by_accident, String
  property :other_death_by_accident, String
  property :other_home_village, String
  property :home_village_id, String
  property :home_village, String
  property :other_home_ta, String
  property :home_ta_id, String
  property :home_ta, String
  property :home_district_id, String
  property :home_district, String
  property :home_country_id, String
  property :home_country, String
  property :other_home_country, String
  property :home_foreign_state, String
  property :home_foreign_district, String
  property :home_foreign_village, String
  property :home_foreign_address, String
  property :other_current_village, String
  property :current_village_id, String
  property :current_village, String
  property :other_current_ta, String
  property :current_ta_id, String
  property :current_ta, String
  property :current_district_id, String
  property :current_district, String
  property :current_country_id, String
  property :current_country, String
  property :other_current_country, String
  property :current_foreign_state, String
  property :current_foreign_district, String
  property :current_foreign_village, String
  property :current_foreign_address, String
  property :died_while_pregnant, String, :default => "N/A"
  property :updated_by, String
  property :voided_by, String
  property :voided_date, Time
  property :voided, TrueClass, :default => false
  property :form_signed, String
  property :approved, String, :default => 'No'
  property :npid, String
  property :approved_by, String
  property :approved_at, Time
  property :delayed_registration, String,  :default =>"No"
  property :registration_type, String, :default => "Normal Cases" # Unnatural Death | Unclaimed bodies | Missing Persons | Death abroad
  property :court_order, String
  property :court_order_details, String 
  property :police_report, String
  property :police_report_details, String
  property :reason_police_report_not_available, String
  property :proof_of_death_abroad, String

  #Person's mother properties
  #property :mother do
  property :mother_id_number, String
  property :mother_first_name, String
  property :mother_middle_name, String
  property :mother_last_name, String
  property :mother_first_name_code, String
  property :mother_last_name_code, String
  property :mother_middle_name_code, String
  property :mother_gender, String
  property :mother_birthdate, Date
  property :mother_birthdate_estimated, String
  property :mother_current_village_id, String
  property :mother_current_ta_id, String
  property :mother_current_district_id, String
  property :mother_current_village, String
  property :mother_current_ta, String
  property :mother_current_district, String
  property :mother_home_village, String
  property :mother_home_ta_id, String
  property :mother_home_district_id, String
  property :mother_home_country_id, String
  property :mother_nationality_id, String
  property :mother_home_village_id, String
  property :mother_home_ta, String
  property :mother_home_district, String
  property :mother_home_country, String
  property :mother_nationality, String
  property :other_mother_nationality, String
  property :mother_occupation, String

  #Address details for foreigner
  property :mother_residential_country_id, String #Country
  property :mother_residential_country, String #Country

  property :mother_foreigner_current_district_id, String #District/State
  property :mother_foreigner_current_village_id, String #Village/Town
  property :mother_foreigner_current_ta_id, String #Address
  property :mother_foreigner_current_district, String #District/State
  property :mother_foreigner_current_village, String #Village/Town
  property :mother_foreigner_current_ta, String #Address

  property :mother_foreigner_home_district_id, String #District/State
  property :mother_foreigner_home_village_id, String #Village/Town
  property :mother_foreigner_home_ta_id, String #Address
  property :mother_foreigner_home_district, String #District/State
  property :mother_foreigner_home_village, String #Village/Town
  property :mother_foreigner_home_ta, String #Address

  #end

  #Person's father properties
  #property :father do
  property :father_id_number, String
  property :father_first_name, String
  property :father_middle_name, String
  property :father_last_name, String
  property :father_first_name_code, String
  property :father_last_name_code, String
  property :father_middle_name_code, String
  property :father_gender, String
  property :father_birthdate, Date
  property :father_birthdate_estimated, String
  property :father_current_village_id, String
  property :father_current_ta_id, String
  property :father_current_district_id, String
  property :father_current_village, String
  property :father_current_ta, String
  property :father_current_district, String
  property :father_home_village_id, String
  property :father_home_ta_id, String
  property :father_home_district_id, String
  property :father_home_country_id, String
  property :father_nationality_id, String
  property :father_home_village, String
  property :father_home_ta, String
  property :father_home_district, String
  property :father_home_country, String
  property :father_nationality, String
  property :other_father_nationality, String
  property :father_occupation, String

  #Address details for foreigner

  property :father_residential_country_id, String #Country
  property :father_residential_country, String #Country

  property :father_foreigner_current_district_id, String #District/State
  property :father_foreigner_current_village_id, String #Village/Town
  property :father_foreigner_current_ta_id, String #Address
  property :father_foreigner_current_district, String #District/State
  property :father_foreigner_current_village, String #Village/Town
  property :father_foreigner_current_ta, String #Address

  property :father_foreigner_home_district_id, String #District/State
  property :father_foreigner_home_village_id, String #Village/Town
  property :father_foreigner_home_ta_id, String #Address
  property :father_foreigner_home_district, String #District/State
  property :father_foreigner_home_village, String #Village/Town
  property :father_foreigner_home_ta, String #Address

  #end

  #Details of senior village member
  property :headman_verified, String
  property :headman_verification_date, Date

  #Details of church elder
  property :church_verified, String
  property :church_verification_date, Date

  #Death informant properties
  #property :informant do
  property :informant_id_number, String
  property :informant_first_name, String
  property :informant_middle_name, String
  property :informant_last_name, String
  property :informant_first_name_code, String
  property :informant_last_name_code, String
  property :informant_middle_name_code, String
  property :informant_relationship_to_deceased, String
  property :informant_relationship_to_deceased_other, String
  property :informant_current_village_id, String
  property :informant_current_ta_id, String
  property :informant_current_district_id, String
  property :informant_current_village, String
  property :informant_current_other_village, String
  property :informant_current_ta, String
  property :informant_current_other_ta, String
  property :informant_current_district, String
  property :informant_current_country, String
  property :other_informant_current_country, String
  property :informant_addressline1, String
  property :informant_addressline2, String
  property :informant_city, String
  property :informant_phone_number, String
  property :informant_foreign_state, String
  property :informant_foreign_district, String
  property :informant_foreign_village, String
  property :informant_foreign_address, String
  property :informant_signed, String
  property :informant_signature_date, Date
  property :informant_designation, String
  property :informant_employment_number, String 
  property :informant_office_name,String
  property :informant_office_address, String
  #end

  property :certifier_name, String
  property :certifier_license_number, String
  property :certifier_signed, String
  property :date_certifier_signed, Date
  property :position_of_certifier, String
  property :other_position_of_certifier, String  

  property :acknowledgement_of_receipt_date, Time, :default => Time.now

  #facility related information
  property :facility_code, String
  property :district_code, String

  property :created_by, String
  property :changed_by, String

  property :_deleted, TrueClass, :default => false
  property :_rev, String


  timestamps!

  design do
    view :by__id

    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"

  end

end

