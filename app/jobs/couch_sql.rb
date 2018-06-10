class CouchSQL
  include SuckerPunch::Job
  workers 1

  def perform()
  	if Rails.env == 'development'
          SuckerPunch.logger.info "Couch to MYSQL"
    end
  	load "#{Rails.root}/bin/script/couch-mysql.rb"
  	CouchSQL.perform_in(12)
  end rescue CouchSQL.perform_in(12)
end

