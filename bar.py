from datetime import datetime
from psutil import disk_usage, sensors_battery, virtual_memory
from psutil._common import bytes2human
from socket import gethostname, gethostbyname
from subprocess import check_output, CalledProcessError
from sys import stdout
from time import sleep

# Casio-style weekday mapping
WEEKDAYS = {
    'Mon': 'MO',
    'Tue': 'TU',
    'Wed': 'WE',
    'Thu': 'TH',
    'Fri': 'FR',
    'Sat': 'SA',
    'Sun': 'SU'
}

def write(data):
    stdout.write('%s\n' % data)
    stdout.flush()

def get_volume():
    try:
        # Get volume percentage
        volume_output = check_output("pactl get-sink-volume @DEFAULT_SINK@", shell=True).decode("utf-8")
        volume_percent = volume_output.split()[4].rstrip('%')
        
        # Check if muted
        mute_output = check_output("pactl get-sink-mute @DEFAULT_SINK@", shell=True).decode("utf-8")
        is_muted = "yes" in mute_output.lower()
        
        if is_muted:
            return f"{volume_percent}% (Muted)"
        else:
            return f"{volume_percent}%"
    except (CalledProcessError, IndexError):
        return "N/A"

def get_vpn_status():
    try:
        # Check if the VPN connection is active using nmcli
        output = check_output("nmcli con show --active", shell=True).decode("utf-8")
        if "integrity2-SE" in output:
            return "Up"
        else:
            return "Down"
    except CalledProcessError:
        return "N/A"

def refresh():
    home_disk = bytes2human(disk_usage('/home').free)
    root_disk = bytes2human(disk_usage('/').free)
    memory = virtual_memory()
    memory_used = bytes2human(memory.used)
    memory_total = bytes2human(memory.total)
    ip = gethostbyname(gethostname())
    try:
        ssid = check_output("iwgetid -r", shell=True).strip().decode("utf-8")
        ssid = "(%s)" % ssid
    except Exception:
        ssid = "None"
    battery = int(sensors_battery().percent)
    status = "Charging" if sensors_battery().power_plugged else "Discharging"
    volume = get_volume()
    vpn_status = get_vpn_status()
    now = datetime.now()
    weekday = WEEKDAYS[now.strftime('%a')]
    day = now.strftime('%d')
    time_str = now.strftime('%H:%M:%S')
    casio_time = f"{weekday} {day} {time_str}"
    format = "🏠 %s 💾 %s 🧠 %s/%s 🌐 %s %s 🔊 %s 🛡️ %s 🔋 %s%% %s ⌚ %s"
    write(format % (home_disk, root_disk, memory_used, memory_total, ip, ssid, volume, vpn_status, battery, status, casio_time))

while True:
    refresh()
    sleep(1)
