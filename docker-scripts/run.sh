#!/bin/bash

install_file="/config/install.sh"

# Install plugins via install.sh
if [ -f "$install_file" ]; then
    echo "Executing $install_file."
    sh $install_file
else
    echo "$install_file not found."
fi

# Start Home Assistant.
python -m homeassistant --config /config &

# Give Home Assistant 5 minutes to start.
# XXX(seth): It would really be nice to find a better way to handle this.
sleep 300

# Start homebridge.
./docker-scripts/run-homebridge.sh
