if Rails.env == 'development'
     SyncData.perform_in(240)
else
	if SETTINGS['site_type'].to_s != "remote"
		 SyncData.perform_in(600)
	else
		 SyncData.perform_in(731)
	end
end

if Rails.env == 'development'
    UpdateSyncStatus.perform_in(600)
else
  	UpdateSyncStatus.perform_in(9000)
end


CouchSQL.perform_in(1200)

midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
now = Time.now
diff = (midnight  - now).to_i
LoadMysql.perform_in(diff)