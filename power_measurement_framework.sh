#!/bin/bash

# Define colors for printouts
# Define colors for printouts
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RESET="\033[0m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
set -e
set -o pipefail
# Impressive entry dialog
clear
echo -e "${GREEN}"
figlet -c 'GLACIATION'
echo -e "${RESET}"
sleep 3  # Pause for a few seconds to allow the user to read the banner

print_banner() {
  echo "+-------------------------------------------------------------+"
  printf "| %-59s |\n" "`date`"
  echo "|                                                             |"
  printf "|`tput bold` %-59s `tput sgr0`|\n" "$@"
  echo "+-------------------------------------------------------------+"
}

# Function to start a generic GLACIATION component
start_generic_component() {
    print_banner "Generic GLACIATION Component"
    # Replace the below command with the actual command to start the component
    # start_generic_component_command
    sleep 2  # Sleep for demonstration purposes
    echo -e "${YELLOW}Generic GLACIATION Component started!${RESET}"
    echo
    echo -e "${GREEN}All GLACIATION platform components started successfully!${RESET}"
}

display_glaciation_info() {
    clear
    echo -e "${GREEN}"
    figlet -c 'GLACIATION'
    echo -e "${CYAN}Green, Privacy-Preserving Data Operations from Edge-to-Cloud.${RESET}"
    echo "Using cutting-edge tech for sustainable and private data handling."
    echo
    echo -e "${YELLOW}WHY CHOOSE GLACIATION?${RESET}"
    echo "Innovative AI & Knowledge Graphs for wide-scale interoperability."
    echo "Data operations that are private, green, and span the entire organization."
    echo -e "${RESET}"
    echo
    echo -e "${MAGENTA}This project has received funding from the European Union’s"
    echo -e "HE research and innovation programme under grant agreement No 101070141.${RESET}"
    echo
    sleep 5  # Pause for a few seconds to allow the user to read the banner
}
# Start Grafana component of Power Measurement Framework
start_grafana() {
    print_banner "Power Measurement Framework: Grafana Component"
    # ... rest of the function ...
}

# Start Prometheus component of Power Measurement Framework
start_prometheus() {
    print_banner "Power Measurement Framework: Prometheus Component"
    # ... rest of the function ...
}

# Start Prometheus Exporters of Power Measurement Framework
end_prometheus_exporters() {
    print_banner "Power Measurement Framework: Prometheus Exporters Complete"
    # ... rest of the function ...
}
deploy_snmp_exporter() {
    print_banner "Power Measurement Framework: SNMP Exporter"
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl is not installed. Please install kubectl and try again."
        exit 1
    fi
    # Define the namespace
    NAMESPACE="monitoring"

    # Check if the namespace exists
    if ! kubectl get namespace "$NAMESPACE" ; then
    #if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        echo "Namespace $NAMESPACE does not exist. Creating it now."
        kubectl create namespace "$NAMESPACE"
        if [ $? -eq 0 ]; then
            echo "Namespace $NAMESPACE created successfully."
        else
            echo "Failed to create namespace $NAMESPACE. Please check for errors and try again."
            exit 1
        fi
    else
        echo "Namespace $NAMESPACE already exists."
    fi


    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "Helm is not installed. Please install Helm and try again."
        exit 1
    fi

    # Check if the Prometheus Community repo is already added; if not, add it
    if ! helm repo list | grep -q "prometheus-community"; then
	echo "Adding prometheus-community"
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
    fi

    # Check if snmp_exporter is already deployed; if not, deploy it
    if ! helm list -n $NAMESPACE | grep -q "snmp-exporter"; then
	echo "Install snmp-exporter"
	helm install snmp-exporter prometheus-community/prometheus-snmp-exporter -n $NAMESPACE
    else
        echo "snmp_exporter is already deployed."
    fi
    # Optional: If there are configuration changes or upgrades needed
    # Uncomment the following lines and replace with your upgrade commands
    # helm upgrade snmp-exporter prometheus-community/prometheus-snmp-exporter --install

    # Output the installation status
    helm status snmp-exporter -n $NAMESPACE
}
deploy_idrac_exporter() {
    print_banner "Power Measurement Framework: iDRAC Exporter"
    SCRIPT_DIR=$(dirname "$0")
    # Ensure kubeconfig is properly set up or exit if not
    if ! kubectl cluster-info &> /dev/null; then
        echo "Error: Kubernetes cluster unreachable. Please ensure your kubeconfig is set up correctly."
        exit 1
    fi

    # Create a ConfigMap from the idrac-config.yaml file
    # Ensure the file path is correct or adjust as necessary
    CONFIGMAP_NAME="idrac-config"
    DAEMONSET_NAME="idrac-exporter"
    # Define the namespace
    NAMESPACE="monitoring"

    # Create the namespace if it doesn't exist
    kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"


    # Check if the ConfigMap already exists
    if kubectl get configmap "$CONFIGMAP_NAME" -n $NAMESPACE -o name >/dev/null 2>&1; then
        echo "ConfigMap $CONFIGMAP_NAME already exists. Skipping creation."
    else
	echo "Creating ConfigMap $CONFIGMAP_NAME..."
        kubectl create configmap idrac-config --from-file="$SCRIPT_DIR/../energy-measurement/idrac/idrac-config.yaml" -n $NAMESPACE
    fi

    # Check for errors creating the ConfigMap
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create ConfigMap."
        exit 1
    fi

    # Apply the DaemonSet to deploy idrac_exporter on all nodes
    kubectl apply -f "$SCRIPT_DIR/../energy-measurement/idrac/idrac-daemonset.yaml" -n $NAMESPACE

    # Check for errors applying the DaemonSet
    if [ $? -ne 0 ]; then
        echo "Error: Failed to apply DaemonSet."
        exit 1
    fi
}
deploy_node_exporter() {
    # Get the absolute directory path of the script
    print_banner "Power Measurement Framework: Node Exporter"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Check if the 'monitoring' namespace exists, if not create it
    if ! kubectl get namespace monitoring &> /dev/null; then
        kubectl create namespace monitoring
    fi

    # Step 1: Deploy node exporter DaemonSet
    # Check if the DaemonSet already exists
    if kubectl get daemonset node-exporter -n monitoring >/dev/null 2>&1; then
        echo "DaemonSet node-exporter already exists. Updating..."
        kubectl apply -f "$SCRIPT_DIR/../energy-measurement/node-exporter/daemonset.yaml"
    else
        echo "Creating DaemonSet node-exporter..."
        kubectl create -f "$SCRIPT_DIR/../energy-measurement/node-exporter/daemonset.yaml"
    fi
    # Check for errors deploying the DaemonSet
    if [ $? -ne 0 ]; then
        echo "Error: Failed to deploy Node Exporter DaemonSet."
        exit 1
    fi

    # Step 2: Confirm DaemonSet is available
    kubectl get daemonset -n monitoring

    # Step 3: Create the service
    if kubectl get service node-exporter -n monitoring >/dev/null 2>&1; then
        echo "Service node-exporter already exists. Updating..."
        kubectl apply -f "$SCRIPT_DIR/../energy-measurement/node-exporter/service.yaml"
    else
        echo "Creating Service node-exporter..."
        kubectl create -f "$SCRIPT_DIR/../energy-measurement/node-exporter/service.yaml"

    fi

    # Check for errors creating the service
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create Node Exporter service."
        exit 1
    fi

    # Step 4: Confirm service’s endpoints are pointing to all the DaemonSet pods
    kubectl get endpoints -n monitoring
}

deploy_prometheus() {
    # Define the namespace and the directory containing the configuration files
    print_banner "Power Measurement Framework: Prometheus Component"
    NAMESPACE="monitoring"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    CONFIG_DIR="$SCRIPT_DIR/../Components/prometheus"


    # Create the namespace if it doesn't exist
    kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

    # Deploy Prometheus components
    for FILE in $(ls $CONFIG_DIR/*.yaml); do
        RESOURCE_TYPE=$(cat $FILE | grep 'kind:' | awk '{print $2}')
        RESOURCE_NAME=$(cat $FILE | grep 'name:' | head -1 | awk '{print $2}')
        echo "Deploying $RESOURCE_TYPE $RESOURCE_NAME..."
        
        # Check if the resource already exists
        if kubectl get $RESOURCE_TYPE $RESOURCE_NAME -n $NAMESPACE >/dev/null 2>&1; then
            echo "$RESOURCE_TYPE $RESOURCE_NAME already exists. Updating..."
            kubectl apply -f $FILE -n $NAMESPACE
        else
            echo "Creating $RESOURCE_TYPE $RESOURCE_NAME..."
            kubectl create -f $FILE -n $NAMESPACE
        fi
    done

    echo "Prometheus deployment completed!"
}
deploy_grafana() {
    print_banner "Power Measurement Framework: Grafana Component"
    # Define the namespace
    NAMESPACE="monitoring"

    # Create the namespace if it doesn't exist
    kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

    # Get the path to the directory containing this script
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    CONFIG_DIR="$SCRIPT_DIR/../Components/grafana"


    # Apply the configuration files to create/update the Grafana deployment and service
    kubectl apply -f "$CONFIG_DIR/grafana-deployment.yaml" -n $NAMESPACE
    kubectl apply -f "$CONFIG_DIR/grafana-service.yaml" -n $NAMESPACE

    echo "Grafana deployment completed!"
}


# Start Kepler component of Power Measurement Framework
start_kepler() {
    print_banner "Power Measurement Framework: Kepler Component"
    # ... rest of the function ...
}
# Start the GLACIATION platform components
power_measurement_framework_start() {
    # Start the Power Measurement Framework components
    display_glaciation_info
    echo -e "${CYAN}Initializing Power Measurement Framework...${RESET}"
    deploy_snmp_exporter
    deploy_idrac_exporter
    deploy_node_exporter
    end_prometheus_exporters
    deploy_prometheus
    deploy_grafana
    start_kepler
}
power_measurement_framework_stop() {
  echo "Stopping the power measurement framework..."
  # Add your stop commands here
}

# Check for the parameter and call the relevant function
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <start|stop>"
  exit 1
fi
# Check if the script is being run as root or with necessary privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with necessary privileges. Exiting."
    exit 1
fi

if [ "$1" = "start" ]; then
  power_measurement_framework_start
elif [ "$1" = "stop" ]; then
  power_measurement_framework_stop
else
  echo "Invalid parameter: $1. Please use 'start' or 'stop'."
  exit 1
fi
