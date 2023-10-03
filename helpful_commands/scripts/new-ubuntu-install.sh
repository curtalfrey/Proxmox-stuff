#!/bin/bash

# Function to add SSH public key to authorized_keys
add_ssh_public_key() {
    echo "Adding SSH public key to authorized_keys..."
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    echo "SSH public key added to authorized_keys file."
}

# Function to handle SSH key generation or overwrite
handle_ssh_keys() {
    # Check if SSH RSA keys exist
    if [[ -f ~/.ssh/id_rsa && -f ~/.ssh/id_rsa.pub ]]; then
        echo "SSH RSA keys exist."
        read -p "Do you want to overwrite existing SSH keys? (y/n): " overwrite_keys
        if [[ $overwrite_keys == "y" ]]; then
            ssh-keygen -t rsa -b 4096
            echo "SSH keys generated."
        else
            echo "SSH keys will not be overwritten."
        fi
    else
        echo "SSH RSA keys do not exist."
        read -p "Do you want to generate SSH keys? (y/n): " generate_keys
        if [[ $generate_keys == "y" ]]; then
            ssh-keygen -t rsa -b 4096
            echo "SSH keys generated."
        fi
    fi
}

# Function to handle changing the hostname
change_hostname() {
    # Display the current hostname
    current_hostname=$(hostname)
    echo "Current hostname: $current_hostname"
    
    # Ask if you want to change the hostname
    read -p "Do you want to change the hostname? (y/n): " change_hostname
    if [[ $change_hostname == "y" ]]; then
        read -p "Enter new hostname: " new_hostname
        hostnamectl set-hostname $new_hostname
        echo "Hostname set to $new_hostname."
        read -p "Is this correct? (y/n): " hostname_correct
        if [[ $hostname_correct != "y" ]]; then
            echo "Hostname will not be changed."
        fi
    fi
}

# Function to handle network settings
edit_network_settings() {
    # Prompt to edit network settings
    read -p "Do you want to edit network settings? (y/n): " edit_network
    if [[ $edit_network == "y" ]]; then
        if [[ -f /etc/netplan/00-install-config.yaml ]]; then
            nano /etc/netplan/00-install-config.yaml
            cat /etc/netplan/00-install-config.yaml
            read -p "Are the network settings correct? (y/n): " network_correct
            if [[ $network_correct != "y" ]]; then
                echo "Network settings will not be applied."
            else
                netplan apply
                echo "Network settings will be applied after reboot."
            fi
        else
            echo "Creating network configuration file: /etc/netplan/00-install-config.yaml"
            echo "network:
  ethernets:
    enp6s18:
      addresses:
      - 192.168.0.222/24
      nameservers:
        addresses:
        - 192.168.0.1
        search: []
      routes:
      - to: default
        via: 192.168.0.1
" | sudo tee /etc/netplan/00-install-config.yaml > /dev/null
            nano /etc/netplan/00-install-config.yaml
            cat /etc/netplan/00-install-config.yaml
            read -p "Are the network settings correct? (y/n): " network_correct
            if [[ $network_correct != "y" ]]; then
                echo "Network settings will not be applied."
            else
                netplan apply
                echo "Network settings will be applied after reboot."
            fi
        fi
    fi
}

# Function to handle attaching Ubuntu Pro subscription key
attach_subscription_key() {
    # Prompt for an Ubuntu Pro subscription key
    read -p "Do you have an Ubuntu Pro subscription key? (y/n): " have_subscription_key
    if [[ $have_subscription_key == "y" ]]; then
        read -p "Enter Ubuntu Pro subscription key: " pro_key
        pro attach $pro_key
    fi
}

# Function to handle adding remote client public keys to authorized_keys
add_remote_pub_keys() {
    while true; do
        read -p "Do you want to add remote client public keys to authorized_keys file? (y/n): " add_pub_keys
        if [[ $add_pub_keys == "y" ]]; then
            echo "Please paste the public keys here (press Ctrl+D when done):"
            temp_pubkeys_file=$(mktemp)
            cat >> "$temp_pubkeys_file"
            
            # Check for duplicate keys and prompt for replacement
            while read -r pubkey; do
                if [[ -n "$pubkey" ]]; then
                    userhost=$(ssh-keygen -l -f /dev/stdin <<< "$pubkey" | awk '{print $3}')
                    if grep -q "$userhost" ~/.ssh/authorized_keys; then
                        existing_key=$(grep "$userhost" ~/.ssh/authorized_keys)
                        if [[ "$pubkey" != "$existing_key" ]]; then
                            read -p "A non-identical key with the same user@hostname already exists in authorized_keys. Replace it with the new key? (y/n): " replace_key
                            if [[ $replace_key == "y" ]]; then
                                sed -i "/$userhost/d" ~/.ssh/authorized_keys
                                echo "$pubkey" >> ~/.ssh/authorized_keys
                                echo "Public key replaced in authorized_keys file."
                            else
                                echo "The existing key will not be replaced."
                            fi
                        else
                            echo "A key with the same user@hostname already exists in authorized_keys."
                            echo "This key will not be added."
                        fi
                    else
                        echo "$pubkey" >> ~/.ssh/authorized_keys
                        echo "Public key added to authorized_keys file."
                    fi
                fi
            done < "$temp_pubkeys_file"
            
            rm -f "$temp_pubkeys_file"
        else
            break
        fi
    done
}

# Function to install required packages
install_required_packages() {
    echo "Updating package cache..."
    sudo apt update
    echo "Upgrading packages..."
    sudo apt upgrade -y
    echo "Removing unnecessary packages..."
    sudo apt autoremove -y
    echo "Installing required packages..."
    sudo apt install -y git wget docker.io docker-compose curl unzip htop python3 python3-pip nfs-common prometheus-node-exporter rkhunter clamav-daemon clamav qemu-guest-agent
}

# Function to handle system reboot
reboot_system() {
    read -p "Do you want to reboot the system? (y/n): " reboot_system
    if [[ $reboot_system == "y" ]]; then
        echo "Rebooting the system..."
        sudo reboot
    fi
}

# Main script execution
handle_ssh_keys
change_hostname
edit_network_settings
attach_subscription_key
add_remote_pub_keys
install_required_packages
reboot_system

echo "Script completed."
