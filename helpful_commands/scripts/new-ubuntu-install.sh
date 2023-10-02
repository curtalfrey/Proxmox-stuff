#!/bin/bash

# Function to check for errors and optionally reboot if unsuccessful
check_and_reboot() {
    if [ $? -eq 0 ]; then
        echo "Success: $1"
    else
        echo "Error: $1"
        prompt_continue
    fi
}

# Function to prompt for continuing despite an error
prompt_continue() {
    if prompt_yes_no "Continue despite the error? ((y)es/(n)o)"; then
        echo "Continuing..."
    else
        echo "Exiting script."
        exit 1
    fi
}

# Function to add SSH public keys to authorized_keys file
manage_ssh_public_keys() {
    while true; do
        read -p "Do you want to (a)dd, (r)emove, or (d)isplay SSH public keys (a/r/d/none)? " ssh_action
        case "$ssh_action" in
            a|A)
                read -p "Enter the SSH public key to add: " ssh_key
                if [ -n "$ssh_key" ]; then
                    echo "$ssh_key" >> ~/.ssh/authorized_keys
                fi
                ;;
            r|R)
                read -p "Enter the SSH public key to remove: " ssh_key
                if [ -n "$ssh_key" ]; then
                    grep -v -F "$ssh_key" ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp
                    mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
                fi
                ;;
            d|D)
                echo "SSH public keys currently in authorized_keys:"
                cat ~/.ssh/authorized_keys
                ;;
            none|None)
                break
                ;;
            *)
                echo "Invalid option. Choose (a)dd, (r)emove, (d)isplay, or (none)."
                ;;
        esac
    done
}

# Function to display the current state of SSH keys
display_ssh_key_state() {
    if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
        echo "SSH keys already exist."
    else
        echo "SSH keys do not exist."
    fi
}

# Function to display the current state of the hostname
display_hostname_state() {
    current_hostname=$(hostname)
    echo "Current Hostname: $current_hostname"
}

# Function to prompt for a yes/no answer, and map "(y)es" to "y" and "(n)o" to "n"
prompt_yes_no() {
    local question="$1"
    local answer
    while true; do
        read -p "$question ((y)es/(n)o): " answer
        answer=${answer,,}  # Convert to lowercase for case-insensitive comparison
        case "$answer" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please enter '(y)es' or '(n)o'." ;;
        esac
    done
}

# Function to gather network configuration for static IP
get_static_ip_config() {
    read -p "Enter the static IP address and subnet in the format IP/Subnet (e.g., 192.168.0.100/24): " static_ip_subnet
    if [[ "$static_ip_subnet" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/([0-9]+)$ ]]; then
        static_ip="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
        echo "Invalid input format. Please enter the IP and subnet in the format IP/Subnet (e.g., 192.168.0.100/24)."
        get_static_ip_config
        return
    fi

    read -p "Enter the gateway IP address: " gateway_ip
}

# Function to edit network configuration using Nano text editor
edit_network_config() {
    # Check if there are any Netplan configuration files in /etc/netplan
    netplan_files=(/etc/netplan/*.yaml)
    if [ ${#netplan_files[@]} -eq 0 ]; then
        echo "No Netplan configuration files found in /etc/netplan."
        return
    fi

    # Display the list of Netplan configuration files
    echo "Available Netplan configuration files in /etc/netplan:"
    for ((i=0; i<${#netplan_files[@]}; i++)); do
        echo "$i: ${netplan_files[$i]}"
    done

    # Prompt the user to select a Netplan configuration file
    read -p "Enter the index of the Netplan configuration file you want to edit: " file_index
    selected_file="${netplan_files[$file_index]}"

    # Open the file for editing in Nano
    nano "$selected_file"

    # Prompt for confirmation
    if prompt_yes_no "Has the configuration file been updated and saved"; then
        # Apply the network configuration
        echo "Applying network configuration..."
        netplan apply
        check_and_reboot "Setting network configuration"
    else
        echo "Network configuration not modified."
    fi
}

# Function to prompt for Ubuntu Pro subscription key
prompt_for_ubuntu_pro_key() {
    read -p "Do you have an Ubuntu Pro subscription? ((y)es/(n)o): " ubuntu_pro_subscription
    ubuntu_pro_subscription=${ubuntu_pro_subscription,,}
    if [ "$ubuntu_pro_subscription" == "y" ] || [ "$ubuntu_pro_subscription" == "yes" ]; then
        read -p "Enter your Ubuntu Pro subscription key: " ubuntu_pro_key
        echo "Attaching Ubuntu Pro subscription..."
        pro attach "$ubuntu_pro_key"
        check_and_reboot "Attaching Ubuntu Pro subscription"
    else
        echo "No Ubuntu Pro subscription key provided. Skipping Ubuntu Pro attachment."
    fi
}

# Function to prompt for detaching and reattaching Ubuntu Pro subscription
detach_and_reattach_ubuntu_pro() {
    if prompt_yes_no "Do you want to detach the current Ubuntu Pro subscription and attach a different one? ((y)es/(n)o)"; then
        echo "Detaching current Ubuntu Pro subscription..."
        pro detach
        check_and_reboot "Detaching Ubuntu Pro subscription"
        prompt_for_ubuntu_pro_key
    else
        echo "Not detaching the current Ubuntu Pro subscription."
    fi
}

# Display current state of SSH keys
display_ssh_key_state
if prompt_yes_no "Do you want to generate SSH keys"; then
    # Generate SSH keys
    echo "Generating SSH keys..."
    ssh-keygen -t rsa -b 4096
    check_and_reboot "Generating SSH keys"
fi

# Display current state of hostname
display_hostname_state
if prompt_yes_no "Do you want to change the hostname"; then
    read -p "Enter the new hostname: " new_hostname

    # Set hostname
    echo "Setting hostname..."
    hostnamectl set-hostname "$new_hostname"
    check_and_reboot "Setting hostname"
fi

# Prompt to edit network configuration
if prompt_yes_no "Do you want to edit network settings"; then
    edit_network_config
fi

# Prompt for Ubuntu Pro subscription key
prompt_for_ubuntu_pro_key

# Prompt for detaching and reattaching Ubuntu Pro subscription
detach_and_reattach_ubuntu_pro

# Install required packages
echo "Installing packages..."
apt update
check_and_reboot "Updating package cache"
apt upgrade -y
check_and_reboot "Upgrading packages"
apt autoremove -y
check_and_reboot "Autoremoving unnecessary packages"
apt install -y git wget curl unzip htop python3 python3-pip nfs-common prometheus-node-exporter rkhunter clamav-daemon clamav qemu-guest-agent
check_and_reboot "Installing packages"

# Ask if the user wants to reboot
if prompt_yes_no "Script complete. Do you want to reboot the system"; then
    echo "Rebooting the system..."
    reboot
else
    echo "Script execution complete."
fi
