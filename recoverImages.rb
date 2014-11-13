require 'fileutils'

class Utilities

	def initialize()

		@@serversInfo = Array.new()
		@@batchsInfo = Array.new()

		@@file = nil
		@@fileName = 'logs.txt'
		@@destination = Dir.getwd()

		# if logs.txt exist, delete it
		deleteLogs()
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
				@batchLocation = server + batch + '.tiff'

				# if server doesn't exist, try with the next server
				if(File.directory?(server))
					writeToLogs(batch, server, 1)
					next
				else
					# if file doesn't exist in this server, try with the next server
					if(File.exists?(@batchLocation))
						writeToLogs(batch, server, 2)
						next
					else
						# if image is found, copy to the destination
						FileUtils.cp(@batchLocation, @@destination)
						writeToLogs(batch, server, 3)
						next
					end
				end
			end
		end
	end

	def copyFiles()
	
		# get the info of the .txt
		@@serversInfo = readInfo("servers.txt")
		@@batchsInfo = readInfo("batchs.txt")

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

	def writeToLogs(batch, server, opt)

		@batch = batch
		@server = server

		@@file = File.open(@@fileName, "a")

		case opt
		when 1
			@@file.write("server: #{server} doesn't exist!")
		when 2			
			@@file.write("batch: #{batch} doesn't exist!")
		when 3
			@@file.write("****** batch: #{batch} copied! ******")
		end	
		@@file.close()
	end

	public :copyFiles
	private :initialize, :readInfo, :findImage, :deleteLogs, :writeToLogs
	protected :initialize, :readInfo, :findImage, :deleteLogs, :writeToLogs
end

class FirstTimeUse

	def self.createFiles

		# if 'servers.txt' doesn't exist, create it
		if(!File.exists?('servers.txt'))
			# create servers.txt
			file = File.open("servers.txt", "w")
			file.write("Elimina esto y escribe los servidores en los que se va a buscar, uno por linea")
			file.close()	
		end

		# if 'batchs.txt' doesn't exist, create it
		if(!File.exists?('batchs.txt'))
			# create batchs.txt
			file = File.open("batchs.txt", "w")
			file.write("Elimina esto y escribe los batchs que se van a buscar, uno por linea")
			file.close()
		end			

		# exit so the user can see the files created
		exit()
	end	
end

# create files id doesn't exists
FirstTimeUse.createFiles()

# run the program
util = Utilities.new()
util.copyFiles()
