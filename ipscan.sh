#!/bin/bash

# Prüfen, ob nmap installiert ist
if ! command -v nmap &>/dev/null; then
    echo "Das Programm 'nmap' ist nicht installiert. Bitte installiere es, um das Skript auszuführen."
    exit 1
fi

# Aktuellen IP-Bereich herausfinden
network=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | awk -F. '{print $1"."$2"."$3".0/24"}' | head -n 1)

# Nmap Scan
echo "Scanning network: $network..."
scan_results=$(nmap -sn "$network" -oG - | awk '/Up$/{print $2, $3}')

# Tabellenkopf mit schmaleren Abständen
printf "\033[1;34m%-17s %-30s\033[0m\n" "IP Address" "Hostname"

# Initialisiere Host-Zähler
host_count=0

# Für jeden gefundenen Host IP und Hostname anzeigen
while read -r ip host; do
    # Überspringe ungültige Zeilen
    if [[ "$ip" == "#" || -z "$ip" ]]; then
        continue
    fi

    # Wenn keine IP-Adresse da ist, verschiebe Hostname in die IP-Spalte
    if [[ "$ip" == "("*")" ]]; then
        host=$ip
        ip="Unknown"
    fi

    # Hostname bereinigen
    hostname=$(echo "$host" | sed -e 's/[()]//g')
    [ -z "$hostname" ] && hostname="Unknown"

    # Ausgabe mit schmaleren Spalten
    printf "%-17s %-30s\n" "$ip" "$hostname"

    # Host-Zähler erhöhen
    ((host_count++))
done <<< "$scan_results"

# Anzahl der gefundenen Hosts ausgeben
echo
echo "Anzahl gefundener Hosts: $host_count"

