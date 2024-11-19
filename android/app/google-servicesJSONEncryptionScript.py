from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64
import json
import os
import secrets

# Secret key (must be 16 bytes for AES-128)
secret_key = secrets.token_bytes(16)
print("secret_ket: ",secret_key)
# IV (Initialization Vector) (must be 16 bytes)
iv = secrets.token_bytes(16)
print("iv: ",iv)

# Secret key (must be 16 bytes for AES-128)
secret_key_hex = secret_key.hex()
print("secret_ket: ",secret_key_hex)
# IV (Initialization Vector) (must be 16 bytes)
iv_hex = iv.hex()
print("iv: ",iv_hex)

# Function to encrypt data
def encrypt_data(data):
    cipher = AES.new(secret_key_hex, AES.MODE_CBC, iv_hex)
    encrypted = cipher.encrypt(pad(data.encode(), AES.block_size))
    return base64.b64encode(encrypted).decode()

# Load the original google-services.json data
with open('google-services.json', 'r') as file:
    json_data = file.read()

# Encrypt the JSON data
encrypted_json = encrypt_data(json_data)

# Save the encrypted data to a new file
with open('encrypted_google-services.json', 'w') as enc_file:
    enc_file.write(encrypted_json)

print("File Encrypted Successfully!")
