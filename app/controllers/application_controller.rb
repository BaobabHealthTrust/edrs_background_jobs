class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def start_sync
  	cron_job_tracker = CronJobsTracker.first
   	now = Time.now
    if SETTINGS["site_type"] == "remote"
        if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 600
           if SuckerPunch::Queue.stats["SyncData"]["workers"]["idle"].to_i == 1 
                SyncData.perform_in(600)
           end
        end
    else
      if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 731
         if SuckerPunch::Queue.stats["SyncData"]["workers"]["busy"].to_i != 1 
              SyncData.perform_in(731)
         end
      end
    end

  	render :text => "ok"
  end

  def start_den_assigment
  	begin
  		cron_job_tracker = CronJobsTracker.first
	   	now = Time.now
	   	if SETTINGS['site_type'].to_s != "facility"
	        last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
	        job_interval = SETTINGS['ben_assignment_interval']
	        job_interval = 1.5 if job_interval.blank?
	        job_interval = job_interval.to_f
	        
	        if (now - last_run_time).to_f > job_interval
	          if SETTINGS['site_type'].to_s != "facility"
	            if (defined? PersonIdentifier.can_assign_den).nil?
	              PersonIdentifier.can_assign_den = true
	            end
	            AssignDen.perform_in(job_interval)
	          end
	          
	        end
	    end
  	rescue Exception => e
  		
  	end

  	render :text => "ok"
  end

  
  def start_couch_to_mysql
  	cron_job_tracker = CronJobsTracker.first
   	now = Time.now
  	if (now - (cron_job_tracker.time_last_sync_to_couch.to_time rescue  Date.today.to_time)).to_i > 12
  			if SuckerPunch::Queue.stats["CouchSQL"]["workers"]["idle"].to_i == 1
            	CouchSQL.perform_in(12)
            end
    end
  	render :text => "ok"
  end
  def start_update_sync
  	if SETTINGS['site_type'].to_s != "facility" && SETTINGS['site_type'].to_s != "remote"
	  	cron_job_tracker = CronJobsTracker.first
	   	now = Time.now
	  	if (now - (cron_job_tracker.time_last_updated_sync.to_time rescue  Date.today.to_time)).to_i > 9000
	            UpdateSyncStatus.perform_in(9000)
	    end
	  end
  	render :text => "ok"
  end
end
