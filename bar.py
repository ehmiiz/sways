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
        if "mullvad" in output.lower() or "wg" in output.lower():
            return "Up"
        else:
            return "Down"
    except CalledProcessError:
        return "N/A"

def get_battery_time():
    try:
        # Get battery time remaining from upower
        output = check_output("upower -i $(upower -e | grep 'BAT') | grep -E 'time to empty|time to full'", shell=True).decode("utf-8").strip()
        if "time to empty" in output:
            time_str = output.split("time to empty:")[1].strip()
            # Convert "3.1 hours" to "3h 6m" format
            if "hours" in time_str:
                hours = float(time_str.split()[0])
                h = int(hours)
                m = int((hours - h) * 60)
                return f"{h}h {m}m"
            elif "minutes" in time_str:
                minutes = int(float(time_str.split()[0]))
                return f"{minutes}m"
            else:
                return time_str
        elif "time to full" in output:
            time_str = output.split("time to full:")[1].strip()
            # Convert "1.2 hours" to "1h 12m" format
            if "hours" in time_str:
                hours = float(time_str.split()[0])
                h = int(hours)
                m = int((hours - h) * 60)
                return f"{h}h {m}m (charging)"
            elif "minutes" in time_str:
                minutes = int(float(time_str.split()[0]))
                return f"{minutes}m (charging)"
            else:
                return f"{time_str} (charging)"
        else:
            return "N/A"
    except (CalledProcessError, IndexError, ValueError):
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
    battery_time = get_battery_time()
    volume = get_volume()
    vpn_status = get_vpn_status()
    now = datetime.now()
    weekday = WEEKDAYS[now.strftime('%a')]
    day = now.strftime('%d')
    time_str = now.strftime('%H:%M:%S')
    casio_time = f"{weekday} {day} {time_str}"
    format = "🏠 %s 💾 %s 🧠 %s/%s 🌐 %s %s 🔊 %s 🛡️ %s 🔋 %s%% %s (%s) ⌚ %s"
    write(format % (home_disk, root_disk, memory_used, memory_total, ip, ssid, volume, vpn_status, battery, status, battery_time, casio_time))

while True:
    refresh()
    sleep(1)
