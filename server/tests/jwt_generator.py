# generate_jwt_key.py
import secrets

secure_jwt_key = secrets.token_urlsafe(32)
print("Your new JWT secret key is:")
print(secure_jwt_key)
