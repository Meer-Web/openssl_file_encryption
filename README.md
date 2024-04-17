# Crypter
Script to encrypt and decrypt files easily using openssl.
## Howto
    ./crypter.sh -[e/d] inputfile [--no-verify]
### Options
    -e for encrypt - Encrypts the filename and adds a hash file.
    -d for decrypt - Decrypts the file and removes crypt files after hash check.
    --no-verify - Decrypts the file without comparing the hash.
## Additional info
Uses des-ede3-cbc pbkdf2 with salt by default but can be configured in the ~/.crypter/.algos file.\
Files are converted using base64 encoding.

Files hash is checked uppon decrypting\
This can be ignored using the --no-verify flag.
