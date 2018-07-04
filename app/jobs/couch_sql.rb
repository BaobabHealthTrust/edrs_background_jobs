class CouchSQL
  include SuckerPunch::Job
  workers 1

  def perform()
  	Kernel.system "bundle exec rake edrs:couch_mysql"
  	if Rails.env == 'development'
          SuckerPunch.logger.info "Couch to MYSQL"
    end
  	CouchSQL.perform_in(12)
  end rescue CouchSQL.perform_in(12)
end

