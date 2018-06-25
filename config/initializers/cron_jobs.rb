if SETTINGS['site_type'] == "hq"
	hq_jobs = HQCronJobsTracker.first
	HQCronJobsTracker.new.save if hq_jobs.blank?
else
	if Rails.env == 'development'
	     SyncData.perform_in(240)
	else
		if SETTINGS['site_type'].to_s != "remote"
			 SyncData.perform_in(600)
		else
			 SyncData.perform_in(731)
		end
	end
end

if Rails.env == 'development'
    UpdateSyncStatus.perform_in(600)
else
  	UpdateSyncStatus.perform_in(9000)
end


CouchSQL.perform_in(30)