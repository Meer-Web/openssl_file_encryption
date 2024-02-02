#!/bin/bash

# Check method
case "$1" in 
	"encrypt")
		METHOD='encrypt'
		;;
	"decrypt")
		METHOD='decrypt'
		;;
	*) 
		echo "Usage: ./crypter.sh [encrypt/decrypt] [inputfile] [outputfile]";
		exit 1
		;;
esac

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

# Check for output file
if [ -n "$3" ]
then
	OUTPUT=$3
	if [ -e "$OUTPUT" ];
	then
		echo "Output file already exist!"
		exit 1
	fi
else
	echo "Please submit a output file"
	exit 1
fi

# Ask for password
echo -en "Encryption password: "
read -s PASSWORD; echo ""

if [ "$PASSWORD" == '' ]
then
	echo "Password not set!"
	exit 2
fi

if [ "$METHOD" == 'encrypt' ]
then
	echo -en "Confirm password: "
	read -s PASSWORD_CONFIRM
	echo ""
	if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]
	then
		echo "Passwords are not matching!"
		exit 2
	fi
fi

case "$METHOD" in 
	"encrypt")
		echo "Encrypting";
		openssl enc -des-ede3-cbc -pbkdf2 -salt -in ${INPUT} -out ${OUTPUT}.temp -k ${PASSWORD}
		base64 ${OUTPUT}.temp > ${OUTPUT}
		rm -f ${OUTPUT}.temp
		echo "Done!"
		exit 0
		;;
	"decrypt")
		echo "Decrypting";
		base64 -d ${INPUT} > ${INPUT}.temp
		openssl enc -d -des-ede3-cbc -pbkdf2 -in ${INPUT}.temp -out ${OUTPUT} -k ${PASSWORD}
		rm -f ${INPUT}.temp
		echo "Done!"
		exit 0
		;;
esac
exit 3
