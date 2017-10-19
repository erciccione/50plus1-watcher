require 'json'
require 'open-uri'
require 'term/ansicolor'


class String
  include Term::ANSIColor
end

def toHs(hash)
	hash / 1000000
end


	# get API of all pools

string = open('http://minexmr.com/pools_hist.json')
response_status = string.status
body = string.read
pools = JSON.parse body

	# get minergate's API
string = open('http://moneropools.com/getstats.php?site=minergate.com')
response_status = string.status
body = string.read
minergate_api = JSON.parse body

	# simplify results
dwarfpool_hr = pools['dwarf'].last
cryptopool_fr_hr = pools['monero.crypto-pool.fr'].last
minexmr_hr = pools['minexmr.com'].last
miningpoolhub_hr = pools['miningpoolhub'].last
nanopool_hr = pools['nanopool'].last
minergate_hr = minergate_api["pool"]["hashrate"] 

	# get network's Hashrate
string = open('http://moneroblocks.info/api/get_stats/')
read_string = string.read
network_hr_raw = JSON.parse read_string
network_hr = network_hr_raw['hashrate']
	
	
attck_hr = ((network_hr / 2) * 1.01 )
pc_hr = 40		# in hs/s
botnum = (attck_hr / pc_hr)


puts "Easy tool who calculates the possibility of a 50+1% attack to the Monero network".bold
puts ""
puts "Current global Hashrate:" + " #{toHs(network_hr).round(2)} MH/s".bold
puts "An attacker should have an hashrate of at least:" + " #{toHs(attck_hr).round(2)} MH/s".bold
puts "or a botnet with" + " #{botnum.to_i} bots.".bold + " (calculated assuming 1 bot = 40 Hs/s)"


	#calculate percentage network
dwarfpool_perc = ((dwarfpool_hr/toHs(network_hr))*100).round(2)
cryptopool_fr_perc = ((cryptopool_fr_hr/toHs(network_hr))*100).round(2)
minexmr_perc = ((minexmr_hr/toHs(network_hr))*100).round(2)
miningpoolhub_perc = ((miningpoolhub_hr/toHs(network_hr))*100).round(2)
nanopool_perc = ((nanopool_hr/toHs(network_hr))*100).round(2)
minergate_perc = ((minergate_hr/network_hr)*100).round(2)

puts ""
puts "List of bigger mining pools and their hashrate:".italic
puts ""
puts "Dwarfpool:".blue + "	#{dwarfpool_hr.round(2)} MH/s" + "	#{dwarfpool_perc}%".bold + " of the network"
puts "MineXMR:".blue + "	#{minexmr_hr.round(2)} MH/s" + "	#{minexmr_perc}%".bold + " of the network"
puts "Cryptopool:".blue + "	#{cryptopool_fr_hr.round(2)} MH/s" + "	#{cryptopool_fr_perc}%".bold + " of the network"
puts "Miningpool Hub:".blue + "	#{miningpoolhub_hr.round(2)} MH/s" + "	#{miningpoolhub_perc}%".bold + " of the network"
puts "Nanopool:".blue + "	#{nanopool_hr.round(2)} MH/s" + "	#{nanopool_perc}%".bold + " of the network"
puts "Minergate:".blue + "	#{toHs(minergate_hr).round(2)} MH/s" + "	#{minergate_perc}%".bold + " of the network"

puts ""
	if (dwarfpool_hr*1000000 || cryptopool_fr_hr*1000000 || minexmr_hr*1000000 || miningpoolhub_hr*1000000 || nanopool_hr*1000000 || minergate_hr)  >= attck_hr
	puts "	DANGER: One of the mining pools has 50.01% of the network hashrate !!".red.bold
	else puts "	None of the pools is close to the 50.01% of the global hashrate".green
	end

