class PersonRecordStatus < CouchRest::Model::Base

	before_save :set_district_code,:set_facility_code, :set_registration_type
	#after_create :insert_update_into_mysql
	#after_save :insert_update_into_mysql

	property :person_record_id, String
	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...
	property :prev_status, String
	property :district_code, String
	property :facility_code, String
	property :comment, String
	property :voided, TrueClass, :default => false
	property :reprint, TrueClass, :default => false
	property :registration_type, String
	property :creator, String

	timestamps!

	design do 
		view :by_status
		view :by_district_code
		view :by_facility_code
	    view :by_person_recent_status,
				 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit(doc['person_record_id'], 1);
	                  }
	                }"
	    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
	    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
	    filter :stats_sync, "function(doc,req) {return doc.district_code != null}"

	end

	def set_district_code
		self.district_code = self.person.district_code
	end

	def set_facility_code
		self.facility_code = self.person.facility_code
	end

	def set_registration_type
		self.registration_type = self.person.registration_type
	end

	def person
	    return Person.find(self.person_record_id)    	
	end

	def self.change_status(person,currentstatus,comment=nil)
		status = PersonRecordStatus.by_person_recent_status.key(person.id).last
		if status.present?
			status.update_attributes({:voided => true})
			PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :prev_status => status.status,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})
		else
			PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})
		end
		
	end
	def insert_update_into_mysql
	    fields  = self.keys.sort
	    sql_record = RecordStatus.where(person_record_status_id: self.id).first
	    sql_record = RecordStatus.new if sql_record.blank?
	    fields.each do |field|
	      next if field == "type"
	      next if field == "_rev"
	      if field =="_id"
	          sql_record["person_record_status_id"] = self[field]
	      else
	          sql_record[field] = self[field]
	      end

	    end
	    sql_record.save
	end
end
