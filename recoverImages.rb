=begin
The purpose of this file is to recover pictures from servers.

So this is how it works...
There are 'x' numbers of server (where x > 0)
There are 'y' numbers of pictures (where y > 0)

I need to find the pictures in those servers. So I place the name of the servers in  servers.txt file 
and the name of the pictures in batches.txt.

This script is going to search for each picture in the servers, in case the picture is found, 
it's going to be copied to the directory where this script is located.
=end

require 'fileutils'

class Utilities

	def initialize()

		@@serversInfo = Array.new()
		@@batchsInfo = Array.new()

		@@file = nil
		@@fileName = 'logs.txt'
		@@destination = Dir.getwd().to_s()

		# if logs.txt exist, delete it
#		deleteLogs()

	end

	def readInfo(fileName)

		@fileName = fileName
		@servers = Array.new()
		@array = Array.new()

		# check if file exists
		if(!File.exists?(@fileName))
			puts("\n\n[x] file #{@fileName} doesn't exist!\n\n")
			exit()
		end

		file = File.open(@fileName, "r")

		# check if file is open
		if(!file)
			puts("\n\n[x] file couldn't be opened! \n\n")
			exit()
		end

		# read file
		@servers = File.foreach(@fileName).first(10000)

		# delete '\n' in every line
		@num = 0
		@servers.each do |server|
			@array[@num] = server.delete("\n")
			@num += 1
		end

		file.close()
		return @array
	end

	def findImage()

		@@batchsInfo.each do |batch|
			@@serversInfo.each do |server|

				@batchLocation = server + batch + '.tif'

				puts("looking for #{batch} in server #{server}")

				# if server doesn't exist, try with the next server
				if(!File.directory?(server))
#					writeToLogs(batch, server, 1)
					puts("can't access this server")
					exit()
					next
				else
					# if file doesn't exist in this server, try with the next server
					if(!File.exists?(@batchLocation))
#						writeToLogs(batch, server, 2)
						puts("#{@batchLocation} doesn't exists")
						next
					else
						# if image is found, copy to the destination
						FileUtils.cp(@batchLocation, @@destination)
						puts("file copied!")
#						writeToLogs(batch, server, 3)
						break
					end
				end	
			end
		end
	end

	def getInfo()

		puts("destination is > #{@@destination}")
	
		# get the info of the .txt
		@@serversInfo = readInfo("servers.txt")
		@@batchsInfo = readInfo("batches.txt")
		removeUselessServers()

		findImage()
	end

	def deleteLogs()

		# if file exists, delete it!
		if(File.exists?(@@fileName))
			File.delete(@@fileName)
		end

		@@file = File.open(@@fileName, "a")
		@@file.close()
	end

	# def writeToLogs(batch, server, opt)

	# 	@batch = batch
	# 	@server = server

	# 	@@file = File.open(@@fileName, "a")

	# 	case opt
	# 	when 1
	# 		@@file.write("server: #{server} doesn't exist!")
	# 	when 2			
	# 		@@file.write("batch: #{batch} doesn't exist!")
	# 	when 3
	# 		@@file.write("****** batch: #{batch} copied! ******")
	# 	end	
	# 	@@file.close()
	# end

	# remove servers that can't be open or doesn't exist
	def removeUselessServers()

		@deletedServers = Array.new()
		@@serversInfo.each do |server|

			# if server doesn't exist, remove it!	
			if(!File.directory?(server))
				@@serversInfo.delete(server)
				@deletedServers.push(server)
			end

			# show the removed servers
			if(@deletedServers.empty?)
				@deletedServers.each do |server|
					puts("server> #{server} not found!")
				end

				# check if user want to continue without this servers
				begin
					puts("do you want to (c)ontinue or (e)xit?")
					answer = gets()
				end while(answer.to_s != "c" || answer.to_s != "e")

				if(answer.to_s == "e")
					exit()
				end
			end
		end		
	end

	public :getInfo
	private :initialize, :readInfo, :findImage, :deleteLogs, :removeUselessServers
	protected :initialize, :readInfo, :findImage, :deleteLogs, :removeUselessServers
end

class FirstTimeUse

	def self.createFiles

		fileWasCreated = false

		# if 'servers.txt' doesn't exist, create it
		if(!File.exists?('servers.txt'))
			# create servers.txt
			file = File.open("servers.txt", "w")
			file.write("Elimina esto y escribe los servidores en los que se va a buscar, uno por linea")
			file.close()	

			puts("file servers.txt was created!")
			fileWasCreated = true
		end

		# if 'batches.txt' doesn't exist, create it
		if(!File.exists?('batches.txt'))
			# create batches.txt
			file = File.open("batches.txt", "w")
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
#FirstTimeUse.createFiles()

# run the program
util = Utilities.new()
util.getInfo()
