#!/bin/bash
# Author: F. Bischof (info@meer-web.nl)
# URL: https://github.com/Meer-Web/openssl_file_encryption

# Check for input file
if [ -n "$2" ]
then
	INPUT=$2
	if [ ! -e "$INPUT" ];
	then
		echo "Input file does not exist!"
		exit 2
	fi
else
	echo "Usage: ./crypter.sh -[e/d] [inputfile]";
	exit 1
fi

# Check if algos are set
if [ ! -f ~/.crypter/.algos ]
then
	mkdir -p ~/.crypter
	echo "ALGOS=\"-des-ede3-cbc -pbkdf2\"" > ~/.crypter/.algos
fi
source ~/.crypter/.algos

# Check method
case "$1" in 
	"-e")
		echo "Encrypting file ${INPUT}"
		OUTPUT="${INPUT}.crypt"
		HASH=$(sha256sum ${INPUT} > ${OUTPUT}.hash)
		openssl enc ${ALGOS} -salt -in ${INPUT} -out ${OUTPUT}.temp > /dev/null 2>&1
		base64 ${OUTPUT}.temp > ${OUTPUT}
		rm -f ${OUTPUT}.temp
		if [ "`stat ${OUTPUT} | grep Size | awk '{ print $2}'`" != 0 ]
		then
			# OK - safe to delete the original input file
			echo "OK - Deleting file ${INPUT}"
			rm -f ${INPUT}
			exit 0
		else
			# NOK - remove empty output file
			echo "CRITICAL - Output file ${OUTPUT} is 0 bytes! Not removing the source file ${INPUT}"
			rm -f ${OUTPUT} ${INPUT}.hash
			exit 2
		fi
		;;
	"-d")
		echo "Decrypting file ${INPUT}";
		OUTPUT=$(echo ${INPUT} | sed 's/\.crypt//')
		base64 -d ${INPUT} > ${INPUT}.temp
		openssl enc -d ${ALGOS} -in ${INPUT}.temp -out ${OUTPUT} > /dev/null 2>&1
		rm -f ${INPUT}.temp
		if [ "`stat ${OUTPUT} | grep Size | awk '{ print $2}'`" != 0 ]
		then
			# SHA256SUM CHECK
			CUR_HASH=$(sha256sum --quiet --check ${OUTPUT}.crypt.hash)
			if [ $? != 0 ]
			then
				# NOK - Hash mismatch
				echo "CRITICAL - Hashes mismatching!"
				rm -f ${OUTPUT}
				exit 2
			else
				# OK - safe to delete the original input file
				echo "OK - Hashes matching, deleting input file"
				rm -f ${INPUT} ${INPUT}.hash
				exit 0
			fi
		else
			# NOK - remove empty output file
			echo "CRITICAL - Output file is 0 bytes! Not removing the input file"
			rm -f ${OUTPUT}
			exit 2
		fi
		exit 0
		;;
	*) 
		echo "Usage: ./crypter.sh -[e/d] [inputfile]";
		exit 1
		;;
esac
exit 3
