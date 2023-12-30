#!/bin/bash

# Function to add SSH public key to authorized_keys
add_ssh_public_key() {
    # Adds the SSH public key from ~/.ssh/id_rsa.pub to ~/.ssh/authorized_keys,
    # allowing SSH access to the server.
    echo "Adding SSH public key to authorized_keys..."
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    echo "SSH public key added to authorized_keys file."
}

# Function to handle SSH key generation or overwrite
handle_ssh_keys() {
    # Checks if SSH RSA keys exist. If they do, it offers the option to overwrite them.
    # If not, it generates new SSH keys. SSH keys provide secure access to the server.
    if [[ -f ~/.ssh/id_rsa && -f ~/.ssh/id_rsa.pub ]]; then
        echo "SSH RSA keys exist."
        read -p "Do you want to overwrite existing SSH keys? (y/n): " overwrite_keys
        if [[ $overwrite_keys == "y" ]]; then
            ssh-keygen -t rsa -b 4096 || { echo "Failed to generate SSH keys"; exit 1; }
            echo "SSH keys generated."
        else
            echo "SSH keys will not be overwritten."
        fi
    else
        echo "SSH RSA keys do not exist."
        read -p "Do you want to generate SSH keys? (y/n): " generate_keys
        if [[ $generate_keys == "y" ]]; then
            ssh-keygen -t rsa -b 4096 || { echo "Failed to generate SSH keys"; exit 1; }
            echo "SSH keys generated."
        fi
    fi
}

# Function to handle changing the hostname
change_hostname() {
    # Displays the current hostname of the server and allows the user to change it if desired.
    # Properly setting the hostname helps identify the server on the network.
    current_hostname=$(hostname)
    echo "Current hostname: $current_hostname"
    
    read -p "Do you want to change the hostname? (y/n): " change_hostname
    if [[ $change_hostname == "y" ]]; then
        read -p "Enter new hostname: " new_hostname
        hostnamectl set-hostname $new_hostname || { echo "Failed to set hostname"; exit 1; }
        echo "Hostname set to $new_hostname."
        read -p "Is this correct? (y/n): " hostname_correct
        if [[ $hostname_correct != "y" ]]; then
            echo "Hostname will not be changed."
        fi
    fi
}

# Function to handle attaching Ubuntu Pro subscription key
attach_subscription_key() {
    # Prompts the user to enter an Ubuntu Pro subscription key. If provided,
    # it attaches the key to the server, enabling access to Ubuntu Pro features.
    read -p "Do you have an Ubuntu Pro subscription key? (y/n): " have_subscription_key
    if [[ $have_subscription_key == "y" ]]; then
        read -p "Enter Ubuntu Pro subscription key: " pro_key
        pro attach $pro_key || { echo "Failed to attach Ubuntu Pro subscription key"; exit 1; }
    fi
}

# Function to handle adding remote client public keys to authorized_keys
add_remote_pub_keys() {
    # Allows the user to paste remote client public keys for SSH access.
    # It checks for duplicate keys and prompts to replace non-identical keys
    # with the same user@hostname. This feature enhances security and user management.
    while true; do
        read -p "Do you want to add remote client public keys to authorized_keys file? (y/n): " add_pub_keys
        if [[ $add_pub_keys == "y" ]]; then
            echo "Please paste the public keys here (press Ctrl+D when done):"
            temp_pubkeys_file=$(mktemp)
            cat >> "$temp_pubkeys_file" || { echo "Error reading public keys"; exit 1; }
            
            while read -r pubkey; do
                if [[ -n "$pubkey" ]]; then
                    userhost=$(ssh-keygen -l -f /dev/stdin <<< "$pubkey" | awk '{print $3}')
                    if grep -q "$userhost" ~/.ssh/authorized_keys; then
                        existing_key=$(grep "$userhost" ~/.ssh/authorized_keys)
                        if [[ "$pubkey" != "$existing_key" ]]; then
                            read -p "A non-identical key with the same user@hostname already exists in authorized_keys. Replace it with the new key? (y/n): " replace_key
                            if [[ $replace_key == "y" ]]; then
                                sed -i "/$userhost/d" ~/.ssh/authorized_keys
                                echo "$pubkey" >> ~/.ssh/authorized_keys || { echo "Failed to add public key to authorized_keys"; exit 1; }
                                echo "Public key replaced in authorized_keys file."
                            else
                                echo "The existing key will not be replaced."
                            fi
                        else
                            echo "A key with the same user@hostname already exists in authorized_keys."
                            echo "This key will not be added."
                        fi
                    else
                        echo "$pubkey" >> ~/.ssh/authorized_keys || { echo "Failed to add public key to authorized_keys"; exit 1; }
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
    # Updates the package cache, upgrades existing packages, removes unnecessary packages,
    # and installs a list of required packages commonly used for server administration and functionality.
    echo "Updating package cache..."
    sudo apt update || { echo "Failed to update package cache"; exit 1; }
    echo "Upgrading packages..."
    sudo apt upgrade -y || { echo "Failed to upgrade packages"; exit 1; }
    echo "Removing unnecessary packages..."
    sudo apt autoremove -y || { echo "Failed to remove unnecessary packages"; exit 1; }
    echo "Installing required packages..."
    sudo apt install -y git wget docker.io docker-compose curl unzip htop python3 python3-pip nfs-common prometheus-node-exporter rkhunter clamav-daemon clamav qemu-guest-agent || { echo "Failed to install required packages"; exit 1; }
}

# Function to install QEMU Guest Agent
install_qemu_guest_agent() {
    read -p "Do you want to install QEMU Guest Agent? (y/n): " install_qemu
    if [[ $install_qemu == "y" ]]; then
        sudo apt install qemu-guest-agent -y || { echo "Failed to install QEMU Guest Agent"; exit 1; }
        echo "QEMU Guest Agent installed."
    fi
}

# Function to install Spice python3-full proxmoxer VDagent (install inside VM guest)
install_spice_vdagent() {
    read -p "Do you want to install python3-full proxmoxer Spice VDagent inside the VM? (y/n): " install_spice
    if [[ $install_spice == "y" ]]; then
        sudo apt install python3-full python3-proxmoxer spice-vdagent -y || { echo "Failed to install Spice VDagent"; exit 1; }
        echo "python3-full proxmoxer Spice VDagent installed inside the VM."
    fi
}

# Function to inform the user about installing virt-viewer-x64-11.0-1.0.msi on Windows
install_virt_viewer_win() {
    echo "To install virt-viewer-x64-11.0-1.0.msi on Windows, run the following commands in PowerShell:"
    echo "1. Invoke-WebRequest -Uri https://releases.pagure.org/virt-viewer/virt-viewer-x64-11.0-1.0.msi -OutFile virt-viewer-x64-11.0-1.0.msi"
    echo "2. Start-Process msiexec -Wait -ArgumentList '/i virt-viewer-x64-11.0-1.0.msi'"
}

# Pause and wait for user acknowledgment
read -p "Press Enter to continue..."

# Function to install Virt-Viewer (on Linux client)
install_virt_viewer() {
    read -p "Do you want to install Virt-Viewer/Manager on Proxmox? (y/n): " install_virt_viewer
    if [[ $install_virt_viewer == "y" ]]; then
        sudo apt install virt-viewer -y || { echo "Failed to install Virt-Viewer"; exit 1; }
        sudo apt install virt-manager -y || { echo "Failed to install Virt-Manager"; exit 1; }
        echo "Virt-Viewer/Manager installed on Proxmox."
    fi
}

# Function to handle network settings
edit_network_settings() {
    # Allows the user to edit network settings by opening the network configuration file.
    # If the file doesn't exist, it creates it with default settings. Proper network
    # configuration ensures the server can communicate on the network.

    # Check if there are any YAML files in /etc/netplan/
    yaml_files=(/etc/netplan/*.yaml)
    
    if [ ${#yaml_files[@]} -gt 0 ]; then
        # If there are YAML files, display them for the user to choose
        echo "Available network configuration files:"
        for ((i=0; i<${#yaml_files[@]}; i++)); do
            echo "$((i+1)). ${yaml_files[i]}"
        done
        read -p "Choose a file number to edit (1-${#yaml_files[@]}): " selected_file_num
        
        if [[ ! "$selected_file_num" =~ ^[0-9]+$ || $selected_file_num -lt 1 || $selected_file_num -gt ${#yaml_files[@]} ]]; then
            echo "Invalid choice. Exiting."
            return
        fi
        
        selected_file="${yaml_files[selected_file_num-1]}"
        
        # Display the chosen file for the user to review
        echo "Chosen network configuration file:"
        cat "$selected_file"
        
        read -p "Do you want to modify the network settings in this file? (y/n): " modify_network
        if [[ $modify_network != "y" ]]; then
            echo "Network settings will not be modified."
            return
        fi
    else
        # If no files exist, create a new one with default settings
        selected_file="/etc/netplan/00-install-config.yaml"
        echo "Creating network configuration file: $selected_file"
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
" | sudo tee "$selected_file" > /dev/null
    fi

    # Open the chosen network configuration file for editing
    nano "$selected_file"

    # Display the contents of the edited/created file for the user to review
    echo "Updated network configuration file:"
    cat "$selected_file"

    # Ask the user to confirm if the network settings are correct
    read -p "Are the network settings correct? (y/n): " network_correct
    if [[ $network_correct != "y" ]]; then
        echo "Network settings will not be applied."
    else
        echo "Network settings will be applied after reboot."
    fi
}

# Function to handle system reboot
reboot_system() {
    # Asks the user if they want to reboot the system. If confirmed, initiates a system reboot to apply changes.
    read -p "Do you want to reboot the system? (y/n): " reboot_system
    if [[ $reboot_system == "y" ]]; then
        echo "Rebooting the system..."
        netplan apply || { echo "Failed to apply network settings"; exit 1; }
        sudo reboot
    fi
}

# Main script execution
install_virt_viewer_win
install_qemu_guest_agent
install_spice_vdagent
install_virt_viewer
handle_ssh_keys
change_hostname
edit_network_settings
attach_subscription_key
add_remote_pub_keys
install_required_packages
reboot_system

echo "Script completed."
