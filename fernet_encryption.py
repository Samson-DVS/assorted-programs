#Author: Visahl Samson (https://github.com/Samson-DVS)
#Date: 07 August 2023
#Description: 🔒 Fernet Encryption with CSV Key Storage 🔑
#This Python script provides a simple implementation of data encryption and decryption using the Fernet symmetric encryption method. The encrypted data and encryption keys are stored in a CSV file for easy management. The script allows users to encrypt sensitive data and save it securely, decrypt data using the appropriate encryption key, and perform key rotation to update encryption keys. Keep your data safe with this easy-to-use encryption tool! 😃🔐
#Note: It's important to handle encryption keys securely to ensure the confidentiality and integrity of encrypted data. Please use this script responsibly and take necessary precautions to protect your encryption keys.

# Import necessary libraries
from cryptography.fernet import Fernet
import csv

# Function to generate a new Fernet key
def generate_key():
    """Generates a new Fernet key."""
    return Fernet.generate_key()

# Function to encrypt data using the given key
def encrypt_data(key, data):
    """Encrypts the given data using the given key."""
    cipher_suite = Fernet(key)
    encrypted_data = cipher_suite.encrypt(data.encode())
    return encrypted_data.decode()

# Function to decrypt data using the given key
def decrypt_data(key, encrypted_data):
    """Decrypts the given data using the given key."""
    cipher_suite = Fernet(key)
    decrypted_data = cipher_suite.decrypt(encrypted_data.encode()).decode()
    return decrypted_data

# Function to save data to a CSV file
def save_to_csv(file_name, data):
    """Saves the given data to a CSV file."""
    with open(file_name, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Encrypted Data', 'Encryption Key'])
        for row in data:
            writer.writerow([row[0], row[1]])

# Function to read data from a CSV file
def read_from_csv(file_name):
    """Reads the given CSV file and returns the data."""
    data = []
    with open(file_name, 'r') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip header row
        for row in reader:
            encrypted_data = row[0]
            key = row[1]
            data.append((encrypted_data, key))
    return data

# Function to encrypt data and save it to a CSV file
def encrypt_and_save():
    """Encrypts the given data and saves it to a CSV file."""
    name = input("Enter the Name to be encrypted: ")
    key = input("Enter the encryption key: ")

    encrypted_data = encrypt_data(key, name)
    print("Encrypted Data:", encrypted_data)

    file_name = 'data.csv'
    data_to_save = [(encrypted_data, key)]
    save_to_csv(file_name, data_to_save)
    print("Data encrypted and saved to", file_name)

# Function to decrypt data from the CSV file and print it
def decrypt_data_from_csv():
    """Decrypts the data from the CSV file and prints it."""
    key_to_find = input("Enter the Key to decrypt the data: ")
    file_name = 'data.csv'
    data = read_from_csv(file_name)

    for encrypted_data, key in data:
        if key == key_to_find:
            decrypted_data = decrypt_data(key_to_find, encrypted_data)
            print("Decrypted Data:", decrypted_data)
            return

    print("Key not found in the CSV file.")

# Function to perform key rotation (updating encryption keys in the CSV file)
def key_rotation():
    """Rotates the keys in the CSV file."""
    old_key = input("Enter the old key: ")
    new_key = input("Enter the new key: ")
    file_name = 'data.csv'
    data = read_from_csv(file_name)

    for idx, (encrypted_data, key) in enumerate(data):
        if key == old_key:
            decrypted_data = decrypt_data(old_key, encrypted_data)
            encrypted_data = encrypt_data(new_key, decrypted_data)
            data[idx] = (encrypted_data, new_key)

    save_to_csv(file_name, data)
    print("Key rotation complete. Data updated in", file_name)

# Main function to run the program
def main():
    """The main function."""
    while True:
        print("\nOptions:")
        print("1. Data Encryption")
        print("2. Data Decryption")
        print("3. Key Rotation")
        print("4. Exit")
        choice = input("Enter your choice (1/2/3/4): ")

        if choice == '1':
            encrypt_and_save()
        elif choice == '2':
            decrypt_data_from_csv()
        elif choice == '3':
            key_rotation()
        elif choice == '4':
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()
