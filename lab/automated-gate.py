def verify_deployment(cpu_load):
    if cpu_load < 80:
        return "SAFE: Proceed with deployment."
    elif cpu_load > 80:
        return "DANGER: CPU load too high. Deployment blocked!"
    else:
        return False
    
cpus = [45, 82, 60]

for cpu in cpus:

    print(verify_deployment(cpu))


    