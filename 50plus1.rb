#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

input = "refresh"
while input == "refresh"

  # Get APIs
  addrs = {
    all_pools: 'http://minexmr.com/pools_hist.json',
    minergate: 'http://moneropools.com/getstats.php?site=minergate.com',
    network: 'https://moneroblocks.info/api/get_stats'
  }
  
  def parse(apis)
    string = open(apis)
    @body = string.read
  end
  
  parse(addrs[:all_pools])
    pools = JSON.parse @body
  parse(addrs[:minergate])
    minergate_api = JSON.parse @body
  parse(addrs[:network])
    network_hr_raw = JSON.parse @body
    
  # Convert H/s -> MH/s
  def toHs(hash)
    hash / 1000000
  end
  
  # Assign values to pools. New pools must be added here
  pools_all = {
    "Dwarfpool": pools['dwarf'].last,
    "Cryptopool": pools['monero.crypto-pool.fr'].last,
    "MineXMR ": pools['minexmr.com'].last,
    "Miningpool Hub": pools['miningpoolhub'].last,
    "Nanopool": pools['nanopool'].last,
    "Supportxmr": pools['supportxmr2'].last
  }
  
  # Get Network's Hashrate
  @network_hr = network_hr_raw['hashrate']
  
  # Operations with global hashrate
  attck_hr = ((@network_hr / 2) * 1.01 )
  fifty_prcnt = (@network_hr / 2)
  SINGLEBOT = 40		# in hs/s
  botnum = (attck_hr / SINGLEBOT)
   
  # Calculate percentage and show results using max 2 decimals
  def ph(po)
    ((po/toHs(@network_hr))*100).round(2)
  end
   
  # Calculate if any pool has > 50% of the hashrate
  status = "safe"
  pools_all.each_value {|p| 
    n = p * 1000000 # Convert MH/s -> H/s
    if n > fifty_prcnt then status = "danger"
    else status = "safe"
    end
  }   
  # Add Minergate to Hash
  pools_all[:"Minergate"] = toHs(minergate_api["pool"]["hashrate"])	# because already in H/s 
  
  # Output on screen
  puts "A simple tool which calculates the possibility of a 50+1% attack to the Monero network".bold
  puts ""
  puts "Current global Hashrate:" + " #{toHs(@network_hr).round(2)} MH/s".bold
  puts "An attacker should have a hashrate of at least:" + " #{toHs(attck_hr).round(2)} MH/s".bold
  puts "or a botnet with" + " #{botnum.to_i} bots.".bold + " (calculated assuming 1 bot = 40 Hs/s)"
  puts ""
  
  puts "List of major mining pools and their hashrate:".italic
  puts ""
  
  # Print pools, hashrate and percent of total hashrate
  pools_all.each {|k,v, prcnt|
  prcnt = ph(v)
  puts "#{k}:".blue + "	#{v.round(2)} MH/s" + "	#{prcnt}%".bold + " of the network"
  }
  puts ""
  
  if status == "safe"
    puts "	None of these pools are close to >50% of the global hashrate".green
  else
    puts "	DANGER: One of the mining pools has reached >50% of the network hashrate !!".red.bold
  end
  
  puts ""
  puts "Type ".italic + "refresh".bold + " to refresh data (new every 60 sec)".italic
  puts "Type ".italic + "exit".bold + " to close program".italic
  puts ""
  
  # Add exit from loop
  input = gets.chomp
  case input
  when "exit" then exit! 
  when "refresh" then system ("clear")
  else puts "error"
  end
end
