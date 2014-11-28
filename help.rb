module Help
	module Files
		# if the user don't specify the file name then use the default
		def self.getFileName(fileName, default)
			@fileName = fileName
			@default = default

			if(@fileName != nil)
				return @fileName
			else
				return @default
			end
		end 

		# create files if doesn't exist
		def self.createFiles(fileWServers, fileWBatches)
			@fileWServers = fileWServers
			@fileWBatches = fileWBatches
			@fileWasCreated = false

			# file within servers
			if(!File.exists?(@fileWServers))
				file = File.open(@fileWServers, "w")
				file.write("Elimina esto y escribe los servidores en los que se va a buscar, uno por linea")
				file.close()

				puts("file #{@fileWServers} was created!")
				fileWasCreated = true
			end

			# file within batches
			if(!File.exists?(@fileWBatches))
				# create batches.txt
				file = File.open(@fileWBatches, "w")
				file.write("Elimina esto y escribe los batchs que se van a buscar, uno por linea")
				file.close()

				puts("file #{@fileWBatches} was created!")
				fileWasCreated = true
			end

			if(fileWasCreated)
				exit()		# exit so the user can see the files created
			end		
		end	

		# read the information on the file within the servers
		def self.readServersFile(fileName, logFile, logs)
			@fileName = fileName
			@logFile = logFile
			@logs = logs

			@servers = Array.new()
			@array = Array.new()

			begin
				file = File.open(@fileName, "r")
			rescue
				fileGlobal.puts("\n\n[x] file #{@fileName} couldn't be opened!\n\n") if(@logs)
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

		def self.readBatchesFile(fileName, extension, logFile, logs)
			@fileName = fileName
			@extension = extension
			@logFile = logFile
			@logs = logs

			@batch = Array.new()
			@array = Array.new()
			@delete = Array.new()

			# if -e [ext] is not used, then use default (.tif)
			if(@extension == nil)
				@extension = ".tif"
			end

			begin
				file = File.open(@fileName, "r")
			rescue
				@logFile.puts("\n\n[x] file #{@fileName} couldn't be opened!\n\n") if(@logs)
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
					@logFile.puts("[] can't append extension to #{@array[@num]}") if(@logs)
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
	end
end
