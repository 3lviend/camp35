# Start search server along with application
# A cheat here is that all child processes gets killed
# with the one that spawned them

pid = Process.spawn "bin/charts_search_server.rb start"
Process.detach pid
