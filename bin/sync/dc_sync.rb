@settings = SYNC_SETTINGS
district_code = SETTINGS['district_code']
person_count = Person.count

source = @settings[:dc]
hq = @settings[:hq]

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Person/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                  }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"] 

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'PersonIdentifier/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                  }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]   

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Audit/facility_sync',
                  query_params: {
                      site_id: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]  

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Sync/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                  }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"] 

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'PersonRecordStatus/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                  }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]  

%x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'CauseOfDeathDispatch/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                  }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]           


if hq[:bidirectional] == true

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  continuous: true,
                  filter: 'Person/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  continuous: true,
                  filter: 'PersonIdentifier/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Audit/facility_sync',
                  continuous: true,
                  query_params: {
                      site_id: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Sync/district_sync',
                  continuous: true,
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  continuous: true,
                  filter: 'PersonRecordStatus/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]

    %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  continuous: true,
                  filter: 'CauseOfDeathDispatch/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   

end



        
                  
        
                
