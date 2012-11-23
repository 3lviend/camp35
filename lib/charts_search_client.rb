require 'msgpack/rpc'
require 'msgpack/rpc/transport/unix'

class ChartsSearchClient

  def initialize
    @builder   = MessagePack::RPC::UNIXTransport.new
    @pool      = MessagePack::RPC::SessionPool.new @builder
    @path      = File.join ["var", "run", "charts_search.sock"]
  end

  def client
    @pool.get_session @path
  end
  
  def ping
    self.client.call :ping
  end

  def add_to_index(chart)
    self.client.call :add_to_index, {id: chart.id, parent_id: chart.parent_id, labels: chart.labels, status: chart.status}
  end

  def reset_index
    self.client.call :reset_index
  end

  def find(phrase)
    self.client.call :find, phrase
  end

  def index_initialized?
    self.client.call :index_initialized?
  end

end
