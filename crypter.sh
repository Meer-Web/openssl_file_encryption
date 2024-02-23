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
		HASH=$(sha256sum $INPUT | awk '{ print $1 }')
		OUTPUT="${INPUT}.${HASH}.crypto"
		openssl enc $ALGOS -salt -in ${INPUT} -out ${OUTPUT}.temp
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
			rm -f ${OUTPUT}
			exit 2
		fi
		;;
	"-d")
		echo "Decrypting file ${INPUT}";
		OUTPUT=$(echo $INPUT | sed 's/\.crypto//')
		HASH=$(echo $OUTPUT | sed 's/^.*\.//')
		base64 -d ${INPUT} > ${INPUT}.temp
		openssl enc -d $ALGOS -in ${INPUT}.temp -out ${OUTPUT}
		rm -f ${INPUT}.temp
		if [ "`stat ${OUTPUT} | grep Size | awk '{ print $2}'`" != 0 ]
		then
			# SHA256SUM CHECK
			CUR_HASH=$(sha256sum ${OUTPUT} | awk '{ print $1 }')
			if [ "${HASH}" != "${CUR_HASH}" ]
			then
				# NOK - Hash mismatch
				echo "CRITICAL - Hashes mismatching!"
				rm -f ${OUTPUT}
				exit 2
			else
				# OK - safe to delete the original input file
				echo "OK - Hashes matching, deleting input file"
				rm -f ${INPUT}
				mv ${OUTPUT} $(echo $OUTPUT | sed 's/\..*//')
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
