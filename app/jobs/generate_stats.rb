class GenerateStats
	include SuckerPunch::Job
  	workers 1
  
  	def perform()
      Kernel.system "bundle exec rake edrs:stats"
      if Rails.env == "development"
      	 GenerateStats.perform_in(233)
      else	
      	GenerateStats.perform_in(511)
      end	
  	end
end