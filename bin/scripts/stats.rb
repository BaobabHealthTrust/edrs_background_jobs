require 'rails'
data_file = "dashboard.json"
newfile = File.open("#{Rails.root}/db/#{data_file}" , "w+")
newfile = File.new("#{Rails.root}/db/#{data_file}" , "w+") if newfile.blank?
beginning= Time.now.beginning_of_year
stats = {}
current_month_num = (Time.now).month.to_i
registered = []
approved = []
printed = []

connection = ActiveRecord::Base.connection

(1..current_month_num).each do |i|
        start_date = beginning
        end_date = beginning.end_of_month

        #registered << Person.by_created_at.startkey(start_date.strftime("%Y-%m-%dT00:00:00:000Z")).endkey(end_date.strftime("%Y-%m-%dT23:59:59.999Z")).each.count

        #approved << PersonRecordStatus.by_status_and_created_at.startkey(["HQ ACTIVE",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey(["HQ ACTIVE",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
        
        #printed << PersonRecordStatus.by_status_and_created_at.startkey(["HQ PRINTED",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey(["HQ PRINTED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count 
        
        registered << connection.select_all("SELECT count(*) as total FROM people WHERE 
                                             DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'").as_json.last['total'] rescue 0

        #approved << connection.select_all("SELECT count(*) as total FROM person_record_status 
        #                                                WHERE status IN('HQ ACTIVE') AND
        #                                                DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'").as_json.last['total'] rescue 0
        
        printed << connection.select_all("SELECT count(*) as total FROM person_record_status 
                                                        WHERE status IN('HQ PRINTED') AND 
                                                        DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'").as_json.last['total'] rescue 0  

        beginning = beginning + 1.months
        
        #puts "Iterator #{start_date} : #{end_date}"

end

stats[:year_registered] = registered
stats[:year_printed] = printed

cummulatives_keys = {}
cummulatives_keys["Newly Received"] = ["HQ ACTIVE"]
cummulatives_keys["Verified by DV"] = ["HQ COMPLETE"]
cummulatives_keys["Marked incomplete by DV"] = ["HQ INCOMPLETE TBA"]
cummulatives_keys["Incomplete Records"]  = ["HQ INCOMPLETE"]
cummulatives_keys["Conflict cases"] = ["HQ CONFLICT"]
cummulatives_keys["Can reject to DC"] = ["HQ CAN REJECT"]
cummulatives_keys["Print Queue"] = ["HQ CAN PRINT"]
cummulatives_keys["Re pritnt- Queue"] = ["HQ REPRINT","HQ REPRINT REQUEST"]
cummulatives_keys["Suspected duplicates"] = ["HQ POTENTIAL DUPLICATE","HQ DUPLICATE"]
cummulatives_keys["Printed"] = ["HQ PRINTED"]
cummulatives_keys["Dispatched"] =  ["HQ DISPATCHED"]

cummulatives = {}
cummulatives_keys.keys.each do |key|

    query =  "SELECT count(*) as total FROM person_record_status WHERE status IN('#{cummulatives_keys[key].join("','")}') AND voided = 0"
    cummulatives[key] = connection.select_all(query).as_json.last['total'] rescue 0
    #cummulatives[key] = PersonRecordStatus.by_record_status.keys(cummulatives_keys[key]).each.count
end
stats[:cummulative] = cummulatives;
#puts "Stats generated :)::::::::::::::)::::::::::::::)::::::::::::::):::::::::::::)::::::::::::::::::::)"


stats["districts"] = {}

District.all.each do |district|
          next if district.name.include?("City")
          beginning= Time.now.beginning_of_year
          current_month_num = (Time.now).month.to_i
          stats["districts"][district.id] = {}
          district_registered = []
          district_approved = []
          district_printed = []

          (1..current_month_num).each do |i|
            start_date = beginning.strftime("%Y-%m-%d 0:00:00:000Z")
            end_date = beginning.end_of_month.strftime("%Y-%m-%d 23:59:59.999Z")

            district_registered << connection.select_all("SELECT count(*) as total FROM people WHERE 
                                                          DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'
                                                          AND district_code ='#{district.id}'").as_json.last['total'] rescue 0

          

            district_approved << connection.select_all("SELECT count(*) as total FROM person_record_status 
                                                        WHERE status IN('HQ ACTIVE') AND
                                                        DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'
                                                        AND district_code ='#{district.id}'").as_json.last['total'] rescue 0
      
            
            district_printed  = connection.select_all("SELECT count(*) as total FROM person_record_status 
                                                        WHERE status IN('HQ PRINTED') AND 
                                                        DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date}' AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date}'
                                                        AND district_code ='#{district.id}'").as_json.last['total'] rescue 0      
            district_printed << district_printed
            beginning = beginning + 1.months
            
            #puts "Iterator #{start_date} : #{end_date}"

          end

          stats["districts"][district.id][:year_registered] = district_registered
          stats["districts"][district.id][:year_approved] = district_approved
          stats["districts"][district.id][:year_printed] = district_printed
end

stats["age_group"] = {}
gender = ["Male","Female"]

gender.each do |sex|
  age_group = ['<1', '1-4', '5-14', '15-24', '25-34', '35-44','45-54', '55-64', '65-74', '75-84', '>85']
  group_stats = []
  age_group.each do |group|

    if group.include?("-")
        age = "BETWEEN #{group.gsub("-"," AND ")}"
    else
        age = group
    end
    sql = "SELECT count(*) as total FROM people
           WHERE date_of_death BETWEEN '2018-01-01' AND '2018-12-31' 
           AND gender='#{sex}' AND  
           DATEDIFF(date_of_death, birthdate)/365 #{age}"
    group_stats << connection.select_all(sql).as_json.last['total'] rescue 0
  end
  stats["age_group"][sex] = group_stats
end

stats["age_group"]["districts"] = {}

District.all.each do |district|
          next if district.name.include?("City")
          stats["age_group"]["districts"][district.id] = {}
          gender = ["Male","Female"]
          gender.each do |sex|
            age_group = ['<1', '1-4', '5-14', '15-24', '25-34', '35-44','45-54', '55-64', '65-74', '75-84', '>85']
            group_stats = []
            age_group.each do |group|
                  if group.include?("-")
                      age = "BETWEEN #{group.gsub("-"," AND ")}"
                  else
                      age = group
                  end
                  sql = "SELECT count(*) as total FROM people
                         WHERE district_code ='#{district.id}' AND date_of_death BETWEEN '2018-01-01' AND '2018-12-31' 
                         AND gender='#{sex}' AND  
                         DATEDIFF(date_of_death, birthdate)/365 #{age}"

                  group_stats << connection.select_all(sql).as_json.last['total'] rescue 0
            end
            stats["age_group"]["districts"][district.id][sex] = group_stats
        end
end


if newfile
         newfile.syswrite(stats.to_json)
else
        puts "Unable to open file"  
end