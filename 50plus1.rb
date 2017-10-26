#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'term/ansicolor'


class String
  include Term::ANSIColor
end

def toHs(hash)
	hash / 1000000
end

input = "refresh"
while input == "refresh"

		# get APIs
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


		# simplify results
	dwarfpool_hr = pools['dwarf'].last
	cryptopool_fr_hr = pools['monero.crypto-pool.fr'].last
	minexmr_hr = pools['minexmr.com'].last
	miningpoolhub_hr = pools['miningpoolhub'].last
	nanopool_hr = pools['nanopool'].last
	supportxmr_hr = pools['supportxmr2'].last
	minergate_hr = minergate_api["pool"]["hashrate"]
	@network_hr = network_hr_raw['hashrate']

	
	attck_hr = ((@network_hr / 2) * 1.01 )
	fifty_prcnt = (@network_hr / 2)
	pc_hr = 40		# in hs/s
	botnum = (attck_hr / pc_hr)


	puts "A simple tool which calculates the possibility of a 50+1% attack to the Monero network".bold
	puts ""
	puts "Current global Hashrate:" + " #{toHs(@network_hr).round(2)} MH/s".bold
	puts "An attacker should have a hashrate of at least:" + " #{toHs(attck_hr).round(2)} MH/s".bold
	puts "or a botnet with" + " #{botnum.to_i} bots.".bold + " (calculated assuming 1 bot = 40 Hs/s)"


	# calculate percentage and display result (max 2 decimals).
	def ph(po)
	((po/toHs(@network_hr))*100).round(2)
	end
		
	dwarfpool_perc = ph(dwarfpool_hr)
	cryptopool_fr_perc = ph(cryptopool_fr_hr)
	minexmr_perc = ph(minexmr_hr)
	miningpoolhub_perc = ph(miningpoolhub_hr)
	nanopool_perc = ph(nanopool_hr)
	minergate_perc = ((minergate_hr/@network_hr)*100).round(2)
	supportxmr_perc = ph(supportxmr_hr)

	puts ""
	puts "List of major mining pools and their hashrate:".italic
	puts ""
	puts "Dwarfpool:".blue + "	#{dwarfpool_hr.round(2)} MH/s" + "	#{dwarfpool_perc}%".bold + " of the network"
	puts "MineXMR:".blue + "	#{minexmr_hr.round(2)} MH/s" + "	#{minexmr_perc}%".bold + " of the network"
	puts "Cryptopool:".blue + "	#{cryptopool_fr_hr.round(2)} MH/s" + "	#{cryptopool_fr_perc}%".bold + " of the network"
	puts "Miningpool Hub:".blue + "	#{miningpoolhub_hr.round(2)} MH/s" + "	#{miningpoolhub_perc}%".bold + " of the network"
	puts "Nanopool:".blue + "	#{nanopool_hr.round(2)} MH/s" + "	#{nanopool_perc}%".bold + " of the network"
	puts "Minergate:".blue + "	#{toHs(minergate_hr).round(2)} MH/s" + "	#{minergate_perc}%".bold + " of the network"
	puts "Supportxmr:".blue + "	#{supportxmr_hr.round(2)} MH/s" + "	#{supportxmr_perc}%".bold + " of the network"

	
	puts ""
		# array containing hashrate of all pools (not minergate)
		# TODO: use the following array for code above
	pools_hr = [dwarfpool_hr, cryptopool_fr_hr, minexmr_hr, miningpoolhub_hr, nanopool_hr, supportxmr_hr]
	
	pools_hr.map! {|n| n * 1000000}
	pools_hr << minergate_hr	# because already in H/s
	pools_hr.select! {|p| p > fifty_prcnt }
	if pools_hr.empty? == true
	puts "	None of these pools are close to >50% of the global hashrate".green
	else
	puts "	DANGER: One of the mining pools has reached >50% of the network hashrate !!".red.bold
	end
	
	puts "
			------------------------
	"
	puts "Type ".italic + "refresh".bold + " to refresh data (new every 60 sec)".italic
	puts "Type ".italic + "exit".bold + " to close program".italic
	puts ""
	
	input = gets.chomp
	case input
	when "exit" then exit! 
	when "refresh" then system ("clear")
	else puts "error"
	end
end
