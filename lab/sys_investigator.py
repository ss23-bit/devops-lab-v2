import os
import platform

def get_system_report():
    return {
        "os": platform.system(),
        "node": platform.node(),
        "current_dir": os.getcwd()
    }    

try:
    print(f"System Report: {get_system_report()}")
except Exception as e:
    print(f"Error: Could not retrieve system information. Detail: {e}")