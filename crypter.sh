#!/bin/bash
# Author: F. Bischof (info@meer-web.nl)

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

# Check if keys are set
if [ ! -f keys ]; then echo "KEYS=\"-des-ede3-cbc -pbkdf2\"" > keys; fi
source keys

# Check method
case "$1" in 
	"-e")
		echo "Encrypting file ${INPUT}"
		OUTPUT="${INPUT}.crypto"
		openssl enc $KEYS -salt -in ${INPUT} -out ${OUTPUT}.temp
		base64 ${OUTPUT}.temp > ${OUTPUT}
		rm -f ${OUTPUT}.temp
		if [ "`stat ${OUTPUT} | grep Size | awk '{ print $2}'`" != 0 ]
		then
			# OK - safe to delete the original input file
			rm -f ${INPUT}
			exit 0
		else
			# NOK - remove empty output file
			echo "Output file is 0 bytes! Not removing the source file"
			rm -f ${OUTPUT}
			exit 2
		fi
		;;
	"-d")
		echo "Decrypting file ${INPUT}";
		OUTPUT="`echo $INPUT | sed 's/\.crypto//'`" #Tim of the last extension in future update"
		base64 -d ${INPUT} > ${INPUT}.temp
		openssl enc -d $KEYS -in ${INPUT}.temp -out ${OUTPUT}
		rm -f ${INPUT}.temp
		exit
		if [ "`stat ${OUTPUT} | grep Size | awk '{ print $2}'`" != 0 ]
		then
			# OK - safe to delete the original input file
			rm -f ${INPUT}
		else
			# NOK - remove empty output file
			echo "Output file is 0 bytes! Not removing the source file"
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
