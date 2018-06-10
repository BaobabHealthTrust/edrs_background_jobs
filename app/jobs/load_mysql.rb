class LoadMysql
	include SuckerPunch::Job
  	workers 1
  	def perform
  		  load "#{Rails.root}/bin/scripts/build_mysql.rb"

        couch_mysql_path =  "#{Rails.root}/config/couchdb.yml"
        db_settings = YAML.load_file(couch_mysql_path)

        couch_db_settings =  db_settings[Rails.env]

        couch_protocol = couch_db_settings["protocol"]
        couch_username = couch_db_settings["username"]
        couch_password = couch_db_settings["password"]
        couch_host = couch_db_settings["host"]
        couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
        couch_port = couch_db_settings["port"]

        changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes"

        data = JSON.parse(RestClient.get(changes_link))

        last_seq = CouchdbSequence.last
        last_seq = CouchdbSequence.new if last_seq.blank?
        last_seq.seq = data["last_seq"] 
        last_seq.save

  		  if Rails.env == "development"
          SuckerPunch.logger.info "Load MYSQL"
        end
        
        if Rails.env == 'development'
        	LoadMysql.perform_in(3600)
        else
          midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
          now = Time.now
          diff = (midnight  - now).to_i
  			  LoadMysql.perform_in(diff)
  		  end
  	end
end