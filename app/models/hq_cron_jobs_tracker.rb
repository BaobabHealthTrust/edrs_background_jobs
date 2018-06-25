class HQCronJobsTracker < CouchRest::Model::Base
  use_database "local"
  property :time_last_synced, Time
  property :time_sync_scheduled, Time
  property :time_last_updated_sync, Time
  property :time_updated_sync_scheduled, Time
  property :time_last_assigned_drn, Time
  property :time_last_sync_to_mysql, Time
  property :time_last_generate_stats, Time
  timestamps!
  design do
    view :by__id
  end

end
