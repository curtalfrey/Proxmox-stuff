#!/usr/bin/env python3

#to run this file type--->     python3 /mnt/my-volume/my-repo/scripts/hash.py


# Prompt the user for a password
password = input("Enter the password you want to hash: ")

# Hash the password
hashed_password = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# Print the hashed password
print("Hashed password:", hashed_password.decode())

# Verify the password against the hashed password
if bcrypt.checkpw(password.encode(), hashed_password):
    print("password matches")
else:
    print("password does not match")
