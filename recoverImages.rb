=begin
The purpose of this file is to copy files from a server to my computer.

This script is going to search for each file in the each server, in case the file is found, 
it's going to be copied to the directory where this script is located.
=end

require 'fileutils'

class Utilities

	def initialize()

		# name of the .txt files
		@@fileServerName = "servers.txt"
		@@fileBatchesName = "batches.txt"

		# get the info of the .txt
		@@serversInfo = readInfoServer(@@fileServerName)
		@@batchsInfo = readInfoBatches(@@fileBatchesName)

		# if one of the files is empty, quit
		if(@@serversInfo.empty? || @@batchsInfo.empty?)
			raise("#{@@fileServerName} or #{@@fileBatchesName} it's empty!")
		end

		removeUselessServers()

		@@destination = Dir.getwd().to_s()

	end

	def readInfoServer(fileName)

		@fileName = fileName
		@servers = Array.new()
		@array = Array.new()

		# check if file exists
		if(!File.exists?(@fileName))
			raise("\n\n[x] file #{@fileName} doesn't exist!\n\n")
		end

		file = File.open(@fileName, "r")

		# check if file is open
		if(!file)
			raise("\n\n[x] file couldn't be opened! \n\n")
		end

		# read file
		@servers = File.foreach(@fileName).first(10000)
		
		@num = 0
		@servers.each do |server|
			# delete '\n' and whitespaces in every line
			@array[@num] = server.delete("\n").delete(" ")

			# if the server doesn't have backslash at the end, add it
			size = server.size()
			if(server[size-1] != '\\' && server[size-2] != '\\')
				@array[@num].insert(-1, '\\')
			end

			@num += 1
		end

		file.close()
		return @array

	end

	def readInfoBatches(fileName)

		@fileName = fileName
		@servers = Array.new()
		@array = Array.new()

		@extension = ".tif"

		# check if file exists
		if(!File.exists?(@fileName))
			raise("\n\n[x] file #{@fileName} doesn't exist!\n\n")
		end

		file = File.open(@fileName, "r")

		# check if file is open
		if(!file)
			raise("\n\n[x] file couldn't be opened! \n\n")
		end

		# read file
		@servers = File.foreach(@fileName).first(10000)
		
		@num = 0
		@servers.each do |server|
			# delete '\n' and whitespaces in every line
			@array[@num] = server.delete("\n").delete(" ")
			
			# append extension
			if(!@array[@num].include?("."))
				@array[@num] << @extension
			end
			puts("[after] array num is >>>>>>>> #{@array[@num]}")

			@num += 1
		end

		file.close()
		return @array

	end

	def findImage()

		@@batchsInfo.each do |batch|
			puts("---------------------")
			puts("batch> #{batch}")
			puts("---------------------")
			@@serversInfo.each do |server|

				@batchLocation = server + batch

				# if server doesn't exist, try with the next server
				if(!File.directory?(server))
					raise("[x] can't access this server")
					next
				else
					# if file doesn't exist in this server, try with the next server
					if(!File.exists?(@batchLocation))
						puts("[] not found in #{@batchLocation} ")
						next
					else
						# if image is found, copy to the destination
						FileUtils.cp(@batchLocation, @@destination)
						puts("[!] file copied!")
						puts("\n\n\n")
						break
					end
				end	
			end
		end

	end

	def start()
	
		findImage()

	end

	# remove servers that can't be open or doesn't exist
	def removeUselessServers()

		@deletedServers = Array.new()

		# servers that can't be accesed, push to '@deletedServers'
		@@serversInfo.each do |server|
			if(!File.directory?(server))
				@deletedServers.push(server)
			end
		end

		# delete servers
		@deletedServers.each do |server|
			@@serversInfo.delete(server)
			puts("server not found!> #{server}")
		end

		# if all servers were removed, exit()
		if(@@serversInfo.empty?)
			puts("\n\n")
			puts("------------------------------------------------------------------------")
			puts("[x] there are no more servers, please check carefully the path of the servers and try again")
			puts("------------------------------------------------------------------------")
			puts("\n\n")
			exit()
		end

		answer = ""

		if(!@deletedServers.empty?)
			# check if user want to continue without this servers
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
		if(!File.exists?('servers.txt'))
			# create servers.txt
			file = File.open('servers.txt', "w")
			file.write("Elimina esto y escribe los servidores en los que se va a buscar, uno por linea")
			file.close()

			puts("file servers.txt was created!")
			fileWasCreated = true
		end

		# if 'batches.txt' doesn't exist, create it
		if(!File.exists?('batches.txt'))
			# create batches.txt
			file = File.open('batches.txt', "w")
			file.write("Elimina esto y escribe los batchs que se van a buscar, uno por linea")
			file.close()

			puts("file batches.txt was created!")
			fileWasCreated = true
		end

		if(fileWasCreated)
			# exit so the user can see the files created
			exit()
		end		
	end	

end

# create files if doesn't exists
FirstTimeUse.createFiles()

# start the program
util = Utilities.new()
util.start()
