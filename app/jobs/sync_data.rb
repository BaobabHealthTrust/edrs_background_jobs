class SyncData
	include SuckerPunch::Job
  	workers 1
  	def perform

    if SETTINGS['site_type'].to_s == "dc"
      load "#{Rails.root}/bin/sync/dc_sync.rb"
    elsif SETTINGS['site_type'].to_s == "facility"
      load "#{Rails.root}/bin/sync/facility_sync.rb"
    elsif SETTINGS['site_type'].to_s == "remote"
      load "#{Rails.root}/bin/sync/sync_all.rb"
    end
      load "#{Rails.root}/bin/sync/barcode_sync.rb"

      sync_tracker = CronJobsTracker.first
      sync_tracker = CronJobsTracker.new if sync_tracker.blank?
      sync_tracker.time_last_synced = Time.now
      sync_tracker.save
      
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync Data"
      end
  	end
end