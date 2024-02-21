# Crypter
Script to encrypt and decrypt files easily using openssl
## Howto
    ./crypter.sh -[e/-d] [inputfile]
### Options
    -e for encrypt
    -d for decrypt
## Additional info
Uses des-ede3-cbc pbkdf2 with salt by default but can be configured in the $KEY variable.\
Files are converted using base64 encoding.
