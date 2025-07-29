#!/bin/bash

# Win + D: Show Desktop
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
echo "✅ Updating: show-desktop to Win+D"

# Win + Tab: Show Workspaces
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>w']"
echo "✅ Updating: toggle-overview  to Win+Tab"

echo "Custom commands section..."

#Installing Flatpak Smile Emoji Picker...
echo "🔧 Setting up Flatpak and Smile Emoji Picker..."

# Install Flatpak if needed
if ! command -v flatpak &> /dev/null; then
    echo "🛠️ Installing Flatpak..."
    sudo apt update && sudo apt install -y flatpak
else
    echo "✅ Flatpak is already installed."
fi

# Add Flathub repo if not present
if ! flatpak remotes | grep -q flathub; then
    echo "📦 Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "✅ Flathub repository already added."
fi

# Install Smile
echo "😄 Installing Smile emoji picker..."
flatpak install -y flathub it.mijorus.smile

# Define an array of custom shortcuts (name, command, binding)
declare -a SHORTCUTS=(
    "Emoji Picker|flatpak run it.mijorus.smile|<Super>period"
    "Screenshot Tool|gnome-screenshot -c -a|<Super><Shift>"
)

# Get current list
CURRENT_LIST=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
CURRENT_LIST=${CURRENT_LIST:1:-1}

# Initialize new entries
NEW_ENTRIES=()

# Add each custom shortcut
for ITEM in "${SHORTCUTS[@]}"; do
    IFS="|" read -r NAME COMMAND BINDING <<< "$ITEM"
    NEW_ID="custom$(date +%s%N)" # unique ID with nanoseconds
    NEW_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$NEW_ID/"
    NEW_ENTRIES+=("'$NEW_PATH'")

    # Set properties
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH name "$NAME"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH command "$COMMAND"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_PATH binding "$BINDING"

    echo "✅ Added: $NAME ($BINDING)"
    sleep 0.1 # brief pause to ensure unique timestamps
done

# Merge with existing list
if [ "$CURRENT_LIST" != "" ]; then
    FINAL_LIST="$CURRENT_LIST, ${NEW_ENTRIES[*]}"
else
    FINAL_LIST="${NEW_ENTRIES[*]}"
fi

# Apply updated list
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$FINAL_LIST]"
