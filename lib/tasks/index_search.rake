namespace :search do

  task :index => :environment do
    c = ChartsSearchClient.new
    puts "Initializing charts search"
    unless c.index_initialized?
      all = WorkChart.leafs_with_labels
      cur = 0
      all.each do |wc| 
        c.add_to_index wc
        cur = cur + 1
        puts "Indexed #{cur} out of #{all.count}"
      end
    else
      puts "already initialized"
    end
  end
 
end
