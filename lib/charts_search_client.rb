require 'msgpack/rpc'

class ChartsSearchClient

  def initialize
    @client = MessagePack::RPC::Client.new "127.0.0.1", 18800
  end
  
  def ping
    @client.call :ping
  end

  def add_to_index(chart)
    @client.call :add_to_index, {id: chart.id, parent_id: chart.parent_id, labels: chart.labels, status: chart.status}
  end

  def reset_index
    @client.call :reset_index
  end

  def find(phrase)
    @client.call :find, phrase
  end

  def index_initialized?
    @client.call :index_initialized?
  end

end
