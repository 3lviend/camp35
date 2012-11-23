#!/usr/bin/env ruby

require 'boson/runner'
require 'msgpack/rpc'
require 'msgpack/rpc/transport/unix'

class SearchIndex

  def initialize
    self.reset!
  end

  def add(word, chart)
    @charts[chart["id"]] ||= []
    @charts[chart["id"]] << chart
    prefixes = self.prefixes_for_word word
    prefixes.each do |prefix|
      @words[prefix] ||= []
      @words[prefix] << chart["id"]
      # puts "Added charts for word #{prefix} Currently indexed by this word: #{@words[prefix].count}"
    end
  end

  def prefixes_for_word(word)
    (0..(word.length - 1)).to_a.map do |i|
      word[0..i].downcase
    end
  end

  def reset!
    @charts = {}
    @words  = {}
  end

  def ids_for_word(word)
    # puts "About to return following ids: #{@words[word.downcase]} for word: \"#{word}\""
    # puts @words
    @words[word.downcase]
  end

  def charts_for_ids(ids)
    ids.map { |id| @charts[id] }.flatten.uniq.reject {|c| c.nil? }
  end

  def words
    @words.keys
  end
end

class SearchHandler

  def initialize(index)
    @index = index
  end

  def ping
    "pong"
  end

  def add_to_index(chart)
    puts "Received: #{chart}"
    words = chart["labels"].map(&:split).flatten.uniq.map(&:strip)
    words.each do |word|
      @index.add word, chart
    end
  end

  def reset_index
    @index.reset!
  end

  def find(phrase)
    puts "Searching for: '#{phrase}'"
    words = phrase.split.map(&:strip)
    # puts "Searching for those words: #{words}"
    ids = words.map { |word| @index.ids_for_word word }.inject {|x,y| x & y}.uniq rescue []
    # puts "Found for phrase #{phrase} following ids: #{ids}"
    @index.charts_for_ids ids
  end

  def index_initialized?
    @index.words.count > 0
  end
end

class ChartsSearchServer < Boson::Runner
  
  def start
    puts "Search server is starting"
    index     = SearchIndex.new
    path      = File.join ["var", "run", "charts_search.sock"]
    if File.exists? path
      File.delete path
    end
    transport = MessagePack::RPC::UNIXServerTransport.new path
    server    = MessagePack::RPC::Server.new
    server.listen transport, SearchHandler.new(index)
    puts "Search server ready."
    server.run
  end

end


if $0 == __FILE__
  if File.new(__FILE__).flock(File::LOCK_EX | File::LOCK_NB)
    ChartsSearchServer.start
  else
    puts "Charts index & search server already running.."
  end
end


