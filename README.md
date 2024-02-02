# Crypter
Script to encrypt and decrypt files easily using openssl
## Howto
 ./crypter.sh [encrypt/decrypt] [inputfile] [outputfile]
## Additional info
Uses des-ede3-cbc pbkdf2 with salt.\
Files are converted using base64 encoding.
