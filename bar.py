from datetime import datetime
from psutil import disk_usage, sensors_battery
from psutil._common import bytes2human
from socket import gethostname, gethostbyname
from subprocess import check_output, CalledProcessError
from sys import stdout
from time import sleep

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

def refresh():
    disk = bytes2human(disk_usage('/home').free)
    ip = gethostbyname(gethostname())
    try:
        ssid = check_output("iwgetid -r", shell=True).strip().decode("utf-8")
        ssid = "(%s)" % ssid
    except Exception:
        ssid = "None"
    battery = int(sensors_battery().percent)
    status = "Charging" if sensors_battery().power_plugged else "Discharging"
    volume = get_volume()
    date = datetime.now().strftime('%h %d %A %H:%M')
    format = "Space: %s | Internet: %s %s | Volume: %s | Battery: %s%% %s | Date: %s"
    write(format % (disk, ip, ssid, volume, battery, status, date))

while True:
    refresh()
    sleep(1)
