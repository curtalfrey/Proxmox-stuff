#!/bin/bash

# Updating and upgrading the system packages
echo "Updating and upgrading the system packages..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean

# Installing Nala
echo "Installing Nala..."
sudo apt install nala

# Updating and upgrading the system packages
echo "Updating and upgrading the system packages..."
sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo nala autopurge && sudo nala clean

# Check if update and upgrade was successful
if [ $? -ne 0 ]; then
  echo "Error: Update and upgrade failed."
  exit 1
fi
echo "Update and upgrade finished successfully."


# Check if Nala was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: Nala installation failed."
  exit 1
fi
echo "Nala installation finished successfully."

# Installing Git
echo "Installing Git..."
sudo nala install -y git

# Check if Git was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: Git installation failed."
  exit 1
fi
echo "Git installation finished successfully."

# Installing Plocate
echo "Installing Plocate..."
sudo nala install -y plocate

# Check if Plocate was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: Plocate installation failed."
  exit 1
fi
echo "Plocate installation finished successfully."

# Installing Docker
echo "Installing Docker..."
sudo nala install -y docker

# Check if Docker was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: Docker installation failed."
  exit 1
fi
echo "Docker installation finished successfully."

# Installing Docker Compose
echo "Installing Docker Compose..."
sudo nala install -y docker-compose

# Check if Docker Compose was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: Docker Compose installation failed."
  exit 1
fi
echo "Docker Compose installation finished successfully."

# Installing snapd
echo "Installing snapd..."
sudo nala install -y snapd

# Check if snapd was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: snapd installation failed."
  exit 1
fi
echo "snapd installation finished successfully."

# Installing maas
echo "Installing maas..."
sudo snap install --channel=3.2 maas

# Check if maas was installed successfully
if [ $? -ne 0 ]; then
  echo "Error: maas installation failed."
  exit 1
fi
echo "maas installation finished successfully."

