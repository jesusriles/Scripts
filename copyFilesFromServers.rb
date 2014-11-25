=begin
The purpose of this file is to copy files from a server to my computer.

This script is going to search for each file in the each server, in case the file is found, 
it's going to be copied to the directory where this script is located.
=end

require 'fileutils'
require 'getoptlong'

class Utilities
	def initialize
		# name of the .txt files
		if($fileservers != nil)
			@@fileServerName = $fileservers
		else
			@@fileServerName = "servers.txt"
			$fileservers = @@fileServerName
		end		
		
		if($filebatches != nil)
			@@fileBatchesName = $filebatches
		else
			@@fileBatchesName = "batches.txt"
			$filebatches = @@fileBatchesName
		end

		# create files if doesn't exists
		FirstTimeUse.createFiles()

		# get the info of the .txt
		@@serversInfo = readInfoServer(@@fileServerName)
		@@batchsInfo = readInfoBatches(@@fileBatchesName)

		# continue at...
		if($continue != nil)
			continue = $continue.dup		# can't modify frozen string (runtimeerror)

			begin
				# if it hasn't an extension, add it
				if(!$continue[-4..-1].include?("."))
					if($extension != nil)
						continue << $extension	
					else
						continue << ".tif"
					end
				end
			rescue
				raise("[x] can't append extension #{$extension} to #{$continue}")
			end

			$continue = continue

			if(@@batchsInfo.include?($continue))
				index = @@batchsInfo.index($continue)

				# remove all batches before $continue
				index.times {
					@@batchsInfo.shift()
				}
			else
				$fileGlobal.puts("[x] Sorry, #{$continue} is not in the list...") if($logs)
				raise("[x] Sorry, #{$continue} is not in the list...")
			end
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

	def readInfoServer(fileName)
		@fileName = fileName
		@servers = Array.new()
		@array = Array.new()

		begin
			file = File.open(@fileName, "r")
		rescue
			$fileGlobal.puts("\n\n[x] file #{@fileName} couldn't be opened!\n\n") if($logs)
			raise("\n\n[x] file #{@fileName} couldn't be opened!\n\n")
		end		

		# read file
		@servers = File.foreach(@fileName)
		
		@num = 0
		@servers.each do |server|
			# delete '\n', tabs and whitespaces in every line
			@array[@num] = server.delete("\n").delete(" ").delete("	")

			size = server.size()

			# check if it uses slash or backslash
			if(server.include?("\\"))
				# check if it has the slash or backslash at the end, if not, add it
				if(server[size-1] != '\\' && server[size-2] != '\\')
					@array[@num].insert(-1, '\\')
				end	
			else
				if(server[size-1] != '/' && server[size-2] != '/')
					@array[@num].insert(-1, '/')
				end	
			end

			@num += 1
		end

		file.close()
		return @array
	end

	def readInfoBatches(fileName)
		@fileName = fileName
		@batch = Array.new()
		@array = Array.new()
		@delete = Array.new()

		# if -e [ext] is not used, then use default (.tif)
		if($extension != nil)
			@extension = $extension
		else
			@extension = ".tif"
		end

		begin
			file = File.open(@fileName, "r")
		rescue
			$fileGlobal.puts("\n\n[x] file #{@fileName} couldn't be opened!\n\n") if($logs)
			raise("\n\n[x] file #{@fileName} couldn't be opened!\n\n")
		end

		# read file
		@batch = File.foreach(@fileName)
		
		@num = 0
		@batch.each do |batch|
			# delete '\n', tabs and whitespaces in every line
			@array[@num] = batch.delete("\n").delete(" ").delete("	")

			# append extension (if last 4 characters doesn't include the point)
			begin
				if(!@array[@num][-4..-1].include?("."))
					@array[@num] << @extension
				end
			rescue
				$fileGlobal.puts("[] can't append extension to #{@array[@num]}") if($logs)
				puts("[] can't append extension to #{@array[@num]}")

				# add 'empty' batches to @remove
				if(@array[@num] == "")
					@delete.push(@array[@num])
				end
				next
			end
			@num += 1
		end

		# delete batches in @remove
		@delete.each do |batch|
			@array.delete(batch)
		end

		file.close()
		return @array
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
	private :initialize, :readInfoServer, :findImage, :removeUselessServers, :readInfoBatches
	protected :initialize, :readInfoServer, :findImage, :removeUselessServers, :readInfoBatches
end

class FirstTimeUse
	def self.createFiles
		fileWasCreated = false

		# if 'servers.txt' doesn't exist, create it
		if(!File.exists?($fileservers))
			# create servers.txt
			file = File.open($fileservers, "w")
			file.write("Elimina esto y escribe los servidores en los que se va a buscar, uno por linea")
			file.close()

			puts("file #{$fileservers} was created!")
			fileWasCreated = true
		end

		# if 'batches.txt' doesn't exist, create it
		if(!File.exists?($filebatches))
			# create batches.txt
			file = File.open($filebatches, "w")
			file.write("Elimina esto y escribe los batchs que se van a buscar, uno por linea")
			file.close()

			puts("file #{filebatches} was created!")
			fileWasCreated = true
		end

		if(fileWasCreated)
			# exit so the user can see the files created
			exit()
		end		
	end	
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

# started time
puts "Started at #{Time.now}"

# global variables
$logs = false
$continue = nil
$extension = nil
$fileservers = nil
$filebatches = nil
$threads

opts = GetoptLong.new(["--logs", "-l", GetoptLong::NO_ARGUMENT],
											["--continue", "-c", GetoptLong::REQUIRED_ARGUMENT],		
											["--extension", "-e", GetoptLong::REQUIRED_ARGUMENT],
											["--fileservers", "-s", GetoptLong::REQUIRED_ARGUMENT],
											["--filebatches", "-b", GetoptLong::REQUIRED_ARGUMENT],
											["--threads", "-t", GetoptLong::NO_ARGUMENT]
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

		when "--threads"
			$threads = true
		end
	}

# start the program
util = Utilities.new()
util.start()

if($logs)
	$fileGlobal.close()
end

# end time
puts "Ends at #{Time.now}"
