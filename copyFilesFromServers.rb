=begin
The purpose of this file is to copy files from a server to my computer.

This script is going to search for each file in the each server, in case the file is found, 
it's going to be copied to the directory where this script is located.
=end

$LOAD_PATH << '.'
require 'fileutils'
require 'getoptlong'
require 'help'

class Utilities
	include Help
	def initialize
		# get the names of the files
		@@fileServerName = Help::Files.getFileName($fileservers, "servers.txt")
		$fileservers = @@fileServerName

		@@fileBatchesName = Help::Files.getFileName($filebatches, "batches.txt")
		$filebatches = @@fileBatchesName		

		# create files if doesn't exists
		Help::Files.createFiles(@@fileServerName, @@fileBatchesName)

		# read the information on the files
		@@serversInfo = Help::Files.readServersFile(@@fileServerName, $fileGlobal, $logs)
		@@batchsInfo = Help::Files.readBatchesFile(@@fileBatchesName, $extension, $fileGlobal, $logs)

		# handle --continue
		if($continue != nil)
			@@batchsInfo = Help::Min.continue($continue, $extension, @@batchsInfo, $fileGlobal, $logs)
		end

		# if one of the files is empty, quit
		if(@@serversInfo.empty? || @@batchsInfo.empty?)
			$fileGlobal.puts("[x] #{@@fileServerName} or #{@@fileBatchesName} is empty!") if($logs)
			raise("[x] #{@@fileServerName} or #{@@fileBatchesName} it's empty!")
		end

		removeUselessServers()

		# get the actual dir
		@@destination = Dir.getwd().to_s()
	end

	def findImage
		@@batchsInfo.each do |batch|
			puts("---------------------")
			puts("batch> #{batch}")
			puts("---------------------")

			if($logs)
				$fileGlobal.puts("---------------------") 
				$fileGlobal.puts("batch> #{batch}")
				$fileGlobal.puts("---------------------")
			end

			@@serversInfo.each do |server|
				@batchLocation = server + batch
				begin
					# if file doesn't exist in this server, try with the next server
					if(!File.exists?(@batchLocation))
						$fileGlobal.puts("[] not found in #{server} ") if($logs)
						puts("[] not found in #{server} ")
						next
					else
						# if image is found, copy to the destination
						begin
							FileUtils.cp(@batchLocation, @@destination)
						rescue
							$fileGlobal.puts("[x] this file couldn't be copied!") if($logs)
							puts("[x] this file couldn't be copied!")
						else
							if($logs)
								$fileGlobal.puts("[!] file copied!")
								$fileGlobal.puts("\n")
							end
							puts("[!] file copied!")
							puts("\n\n\n")
							break
						end
					end
				rescue
					# this point should actually never be reached
					# if something went wrong here, it's probably cause the server couldn't be accessed
					puts("Something went wrong!!") if($logs)
					raise("Something went wrong!!")
				end
			end
		end
	end

	def start
		findImage()
	end

	# remove servers that can't be open or doesn't exist
	def removeUselessServers()
		@deletedServers = Array.new()

		# servers that can't be accessed, push to '@deletedServers'
		@@serversInfo.each do |server|
			if(!File.directory?(server))
				@deletedServers.push(server)
			end
		end

		# delete servers
		@deletedServers.each do |server|
			@@serversInfo.delete(server)
			$fileGlobal.puts("[x] server not found! (removed)> #{server}") if($logs)
			puts("[x] server not found! (removed)> #{server}")
		end

		# if all servers were removed, exit()
		if(@@serversInfo.empty?)
			puts("\n\n")
			puts("------------------------------------------------------------------------")
			puts("[x] there are no more servers, please check carefully the path of the servers and try again")
			puts("------------------------------------------------------------------------")
			puts("\n\n")
			
			if($logs)
				$fileGlobal.puts("\n\n")
				$fileGlobal.puts("------------------------------------------------------------------------")
				$fileGlobal.puts("[x] there are no more servers, please check carefully the path of the servers and try again")
				$fileGlobal.puts("------------------------------------------------------------------------")
				$fileGlobal.puts("\n\n")
			end
			exit()
		end

		# check if user want to continue without this servers
		answer = ""
		if(!@deletedServers.empty?)
			begin
				puts("do you want to (c)ontinue or (e)xit?")
				answer = gets().delete("\n")
			end while(answer != "e" && answer != "c")

			if(answer == "e")
				exit()
			end
		end
	end

	public :start
	private :initialize, :findImage, :removeUselessServers
	protected :initialize, :findImage, :removeUselessServers
end

def createLogs
	# create logs file
	begin
		$fileGlobal = File.open("logs.txt", "w+")
	rescue
		raise("[x] couldn't create logs!")
	end
	$logs = true
end

# global variables
$logs = false
$continue = nil
$extension = nil
$fileservers = nil
$filebatches = nil

opts = GetoptLong.new(["--logs", "-l", GetoptLong::NO_ARGUMENT],
											["--continue", "-c", GetoptLong::REQUIRED_ARGUMENT],		
											["--extension", "-e", GetoptLong::REQUIRED_ARGUMENT],
											["--fileservers", "-s", GetoptLong::REQUIRED_ARGUMENT],
											["--filebatches", "-b", GetoptLong::REQUIRED_ARGUMENT]
	)

opts.each { |option, value|
		case option
		when "--logs"
			createLogs()

		when "--continue"
			$continue = value.to_s()

		when "--extension"

			$extension = value.to_s()
			local = $extension.dup		# can't modify frozen string (runtimeerror)

			if(!local.include?("."))
				local.insert(0, '.')
			end

			$extension = local.dup
		when "--fileservers"
			$fileservers = value.to_s()

		when "--filebatches"
			$filebatches = value.to_s()
		end
	}

# start the program
util = Utilities.new()
util.start()

if($logs)
	$fileGlobal.close()
end

