# How to install (Ubuntu 22+)

1. Install and start microk8s (https://microk8s.io/)

2. Install dependencies for the scripts

```
    brew install kubectl helm figlet
```

3. Install performance framework

```
    power_measurement_framework.sh start
```

4. login to grafana with default username/password (admin/admin)

5. Proxy the grafana to localbox

```
    kubectl port-forward deployment/grafana 3000:3000 --namespace monitoring
```

6. Import dashboards 

- Prometheus datasource
    ```
        curl -X POST --insecure \
            -u "admin:admin" \
            -H "Content-Type: application/json" \
            -d @grafana-dashboards/datasource.json http://localhost:3000/api/datasources
    ```
- Kepler exporter dashboard
    ```
        curl -X POST --insecure \
            -u "admin:admin" \
            -H "Content-Type: application/json" \
            -d @grafana-dashboards/Kepler-Exporter.json http://localhost:3000/api/dashboards/import
    ```
- Node exporter dashboard
    ```
        curl -X POST --insecure \
            -u "admin:admin" \
            -H "Content-Type: application/json" \
            -d @grafana-dashboards/node_exporter_full.json http://localhost:3000/api/dashboards/import
    ```

# Troubleshooting:
- There is a difference of kepler in cloud and kepler in k8s on bare metal see the link for differences (https://www.cncf.io/blog/2023/10/11/exploring-keplers-potentials-unveiling-cloud-application-power-consumption/)
- https://sustainable-computing.io/usage/trouble_shooting/
- The example of the log of kepler installed on kubernetes running on bare metal. Note that eBPF module is expected to be started. (see example of log below)

```
| I0122 09:44:37.359991       1 gpu.go:46] Failed to init nvml, err: could not init nvml: error opening libnvidia-ml.so.1: libnvidia-ml.so.1: cannot open shared object file: No such file or directory           │
│ I0122 09:44:37.362470       1 qat.go:35] Failed to init qat-telemtry err: could not get qat status exit status 127                                                                                              │
│ I0122 09:44:37.366026       1 exporter.go:157] Kepler running on version: c1cae95                                                                                                                               │
│ I0122 09:44:37.366037       1 config.go:274] using gCgroup ID in the BPF program: true                                                                                                                          │
│ I0122 09:44:37.366373       1 config.go:276] kernel version: 6.5                                                                                                                                                │
│ I0122 09:44:37.366423       1 config.go:301] The Idle power will be exposed. Are you running on Baremetal or using single VM per node?                                                                          │
│ I0122 09:44:37.366429       1 exporter.go:169] LibbpfBuilt: false, BccBuilt: true                                                                                                                               │
│ I0122 09:44:37.366433       1 exporter.go:188] EnabledBPFBatchDelete: true                                                                                                                                      │
│ I0122 09:44:37.366458       1 power.go:54] use sysfs to obtain power                                                                                                                                            │
│ I0122 09:44:37.366463       1 redfish.go:169] failed to get redfish credential file path                                                                                                                        │
│ I0122 09:44:37.367526       1 acpi.go:67] Could not find any ACPI power meter path. Is it a VM?                                                                                                                 │
│ I0122 09:44:37.398858       1 exporter.go:203] Initializing the GPU collector                                                                                                                                   │
│ I0122 09:44:43.401662       1 watcher.go:66] Using in cluster k8s config                                                                                                                                        │
│ cannot attach kprobe, probe entry may not exist                                                                                                                                                                 │
│ I0122 09:44:44.281678       1 bcc_attacher.go:94] attaching kprobe to finish_task_switch failed, trying finish_task_switch.isra.0 instead                                                                       │
│ I0122 09:44:44.329813       1 bcc_attacher.go:129] Successfully load eBPF module from using bcc                                                                                                                 │
│ I0122 09:44:44.329826       1 bcc_attacher.go:187] Successfully load eBPF module from bcc with option: [-DMAP_SIZE=10240 -DNUM_CPUS=16 -DSAMPLE_RATE=0 -DSET_GROUP_ID]                                          │
│ I0122 09:44:44.339444       1 container_energy.go:114] Using the Ratio/DynPower Power Model to estimate Container Platform Power                                                                                │
│ I0122 09:44:44.339451       1 container_energy.go:115] Container feature names: [cpu_instructions]                                                                                                              │
│ I0122 09:44:44.339458       1 container_energy.go:124] Using the Ratio/DynPower Power Model to estimate Container Component Power                                                                               │
│ I0122 09:44:44.339461       1 container_energy.go:125] Container feature names: [cpu_instructions cpu_instructions cache_miss   gpu_sm_util]                                                                    │
│ I0122 09:44:44.339466       1 process_power.go:113] Using the Ratio/DynPower Power Model to estimate Process Platform Power                                                                                     │
│ I0122 09:44:44.339468       1 process_power.go:114] Container feature names: [cpu_instructions]                                                                                                                 │
│ I0122 09:44:44.339473       1 process_power.go:123] Using the Ratio/DynPower Power Model to estimate Process Component Power                                                                                    │
│ I0122 09:44:44.339476       1 process_power.go:124] Container feature names: [cpu_instructions cpu_instructions cache_miss   gpu_sm_util]                                                                       │
│ I0122 09:44:44.340034       1 node_platform_energy.go:53] Using the LinearRegressor/AbsPower Power Model to estimate Node Platform Power                                                                        │
│ I0122 09:44:44.340559       1 exporter.go:267] Started Kepler in 6.974544982s 
```