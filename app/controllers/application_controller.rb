class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def start_sync
  	cron_job_tracker = CronJobsTracker.first
   	now = Time.now
    if SETTINGS["site_type"] == "remote"
        if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 311
                SyncData.perform_in(311)
        end
    else
      if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 311
              SyncData.perform_in(311)
      end
    end

  	render :text => "ok"
  end

  
  def start_couch_to_mysql
  	cron_job_tracker = CronJobsTracker.first
   	now = Time.now
  	if (now - (cron_job_tracker.time_last_sync_to_couch.to_time rescue  Date.today.to_time)).to_i > 12
            	CouchSQL.perform_in(12)
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

  def start_generate_stats
      cron_job_tracker = HQCronJobsTracker.first
      now = Time.now
      if (now - (cron_job_tracker.time_last_generate_stats.to_time rescue  Date.today.to_time)).to_i > 700
               GenerateStats.perform_in(700)
               cron_job_tracker.time_last_generate_stats = now + 700.seconds
               cron_job_tracker.save
     end
     render :text => "ok"
  end

  def get_stats
    file_name = Rails.root.join('db', 'dashboard.json')
    #file_name = Rails.root.join('db', 'dashboardtest.json')
    fileinput = JSON.parse(File.read(file_name))
    render :text => fileinput.to_json
  end
end
