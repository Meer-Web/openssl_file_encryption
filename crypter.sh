#!/bin/bash
# Author: F. Bischof (info@meer-web.nl)
KEYS="-des-ede3-cbc -pbkdf2"

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
	echo "Please submit a input file"
	exit 1
fi

# Check method
case "$1" in 
	"-e")
		METHOD='encrypt'
		OUTPUT="${INPUT}.crypto"
		;;
	"-d")
		METHOD='decrypt'
		OUTPUT="`echo $INPUT | sed 's/\.crypto//'`"
		;;
	*) 
		echo "Usage: ./crypter.sh -[e/d] [inputfile]";
		exit 1
		;;
esac

case "$METHOD" in 
	"encrypt")
		echo "Encrypting";
		openssl enc $KEYS -salt -in ${INPUT} -out ${OUTPUT}.temp
		base64 ${OUTPUT}.temp > ${OUTPUT}
		rm -f ${OUTPUT}.temp
		rm -f ${INPUT}
		echo "Done!"
		exit 0
		;;
	"decrypt")
		echo "Decrypting";
		base64 -d ${INPUT} > ${INPUT}.temp
		openssl enc -d $KEYS -in ${INPUT}.temp -out ${OUTPUT}
		rm -f ${INPUT}.temp
		rm -r ${INPUT}
		echo "Done!"
		exit 0
		;;
esac
exit 3
