import os
import subprocess


''' Return a list with the formats supported by mat2 (this is extracted from mat2 --list) '''
def getSupportedFormatsByMat2():
	listWithSupportedFormats = []
	result = subprocess.run(['mat2', '--list'], stdout=subprocess.PIPE)
	
	for line in result.stdout.decode('utf-8').split("\n"):
		onlyFormats = line[line.find('(')+1:line.find(')')]

		# if there is more than 1 format in this line, split them and add them to the list
		if onlyFormats.find(',') != -1:
			for singleFormat in onlyFormats.split(","):
				listWithSupportedFormats.append(singleFormat.strip())
		else:
			for singleFormat in onlyFormats.split('\n'):
				listWithSupportedFormats.append(singleFormat.strip())

	# remove from the list the (1) "[+] Supported formats" label and (2) an empty space that was somehow added at the end
	listWithSupportedFormats.pop(listWithSupportedFormats.index("[+] Supported formats"))
	listWithSupportedFormats.pop(listWithSupportedFormats.index(""))

	return listWithSupportedFormats


''' Input: (1) file that we want to verify if works with mat2 and (2) list with supported formats
	Output: Return true if the file is compatible with mat2, else return false '''
def checkIfFileCompatibleWithMat2(file="empty", listWithSupportedFormats="empty"):

	if file == "empty" or listWithSupportedFormats == "empty":
		return false

	# get the extension from the file
	extension = file.split(".")[1]
	extension = "." + extension

	if extension in listWithSupportedFormats:
		print("[+] File: {} is supported by mat2 (extension checked: {}).".format(file, extension))
		return True
	else:
		print("[-] File: {} is NOT supported by mat2 (extension checked: {}".format(file, extension))
		return False


# checkIfFileCompatibleWithMat2("randomFile.txt", getSupportedFormatsByMat2())

'''
Check mat2
- https://tails.boum.org/doc/sensitive_documents/metadata/index.en.html
- https://tails.boum.org/doc/sensitive_documents/sound_and_video/index.en.html

Check file, stat, exiftool commands
- https://unix.stackexchange.com/questions/243509/how-to-print-metadata-of-a-file-with-the-help-of-command-line
'''
