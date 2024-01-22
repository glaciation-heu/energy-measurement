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
  local color=$1
  shift  # Shift the arguments so $@ does not include the first color parameter
  echo "+-------------------------------------------------------------+"
  printf "| %-59s |\n" "$(date)"
  echo "|                                                             |"
  printf "|${color}`tput bold` %-59s `tput sgr0`${RESET}|\n" "$@"
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
display_power_measurement_info() {
    echo -e "${GREEN}"
    figlet -c 'Power Measurement Framework'
    echo -e "${CYAN}Development of a power and performance measurement framework for GLACIATION.${RESET}"
    echo "Gathers metrics of all power consumption through various power meters on the platform."
    echo
    echo -e "${YELLOW}FRAMEWORK COMPONENTS:${RESET}"
    echo "1. Metric gathering system to collect detailed power usage data."
    echo "2. Tool for runtime system information collection across the GLACIATION platform."
    echo "3. Performance monitoring library to record run-time performance statistics and code trace information."
    echo
    echo -e "${MAGENTA}Ensuring efficient and optimized power utilization in serial and parallel computing environments.${RESET}"
    echo
    sleep 5  # Pause for a few seconds to allow the user to read the banner
}

deploy_snmp_exporter() {
    print_banner $YELLOW "Power Measurement Framework: SNMP Exporter Starting"
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl is not installed. Please install kubectl and try again."
        exit 1
    fi
    # Define the namespace
    NAMESPACE="monitoring"

    # Check if the namespace exists
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        echo "Namespace $NAMESPACE does not exist. Creating it now."
        kubectl create namespace "$NAMESPACE" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Namespace $NAMESPACE created successfully."
        else
            echo "Failed to create namespace $NAMESPACE. Please check for errors and try again."
            exit 1
        fi
    fi

    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "Helm is not installed. Please install Helm and try again."
        exit 1
    fi

    # Check if the Prometheus Community repo is already added; if not, add it
    if ! helm repo list | grep "prometheus-community" &> /dev/null; then
        echo "Adding prometheus-community"
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts &> /dev/null
        helm repo update &> /dev/null
    fi

    # Check if snmp_exporter is already deployed; if not, deploy it
    if ! helm list -n $NAMESPACE | grep "snmp-exporter" &> /dev/null; then
        echo "Install snmp-exporter"
        helm install snmp-exporter prometheus-community/prometheus-snmp-exporter -n $NAMESPACE &> /dev/null
        if [ $? -eq 0 ]; then
            echo "snmp_exporter installed successfully."
        else
            echo "Failed to install snmp_exporter. Please check for errors and try again."
            exit 1
        fi
    fi

    # Output the installation status
    if ! helm status snmp-exporter -n $NAMESPACE &> /dev/null; then
        echo "Failed to get the status of snmp_exporter. Please check for errors."
        exit 1
    fi
    print_banner $GREEN "Power Measurement Framework: SNMP Exporter Started"
}

deploy_idrac_exporter() {
    print_banner $YELLOW "Power Measurement Framework: iDRAC Exporter Starting"
    SCRIPT_DIR=$(dirname "$0") >/dev/null 2>&1
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
    kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE" >/dev/null 2>&1
    # Check if the ConfigMap already exists
    if ! kubectl get configmap "$CONFIGMAP_NAME" -n "$NAMESPACE" -o name >/dev/null 2>&1; then
	    if ! kubectl create configmap "$CONFIGMAP_NAME" --from-file="$SCRIPT_DIR/../energy-measurement/idrac/idrac-config.yaml" -n "$NAMESPACE" >/dev/null 2>&1; then
		    echo "Error: Failed to create ConfigMap."
		    exit 1
	    fi
    fi


    # Apply the DaemonSet to deploy idrac_exporter on all nodes
    if ! kubectl apply -f "$SCRIPT_DIR/../energy-measurement/idrac/idrac-daemonset.yaml" -n $NAMESPACE >/dev/null 2>&1; then
	    echo "Error: Failed to apply DaemonSet."
	    exit 1
    fi
    print_banner $GREEN "Power Measurement Framework: iDRAC Exporter Started"
}


deploy_node_exporter() {
    print_banner $YELLOW "Power Measurement Framework: Node Exporter Starting"
    # Get the absolute directory path of the script
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Check if the 'monitoring' namespace exists, if not create it
    if ! kubectl get namespace monitoring &> /dev/null; then
        kubectl create namespace monitoring &> /dev/null
    fi

    # Step 1: Deploy node exporter DaemonSet
    # Check if the DaemonSet already exists
    if kubectl get daemonset node-exporter -n monitoring &> /dev/null; then
        kubectl apply -f "$SCRIPT_DIR/../energy-measurement/node-exporter/daemonset.yaml" &> /dev/null
    else
        kubectl create -f "$SCRIPT_DIR/../energy-measurement/node-exporter/daemonset.yaml" &> /dev/null
    fi

    # Check for errors deploying the DaemonSet
    if [ $? -ne 0 ]; then
        echo "Error: Failed to deploy Node Exporter DaemonSet." >&2
        exit 1
    fi

    # Step 2: Confirm DaemonSet is available
    # kubectl get daemonset -n monitoring &> /dev/null
    # This check is commented out because it does not alter the state and we're suppressing output.

    # Step 3: Create the service
    if kubectl get service node-exporter -n monitoring &> /dev/null; then
        kubectl apply -f "$SCRIPT_DIR/../energy-measurement/node-exporter/service.yaml" &> /dev/null
    else
        kubectl create -f "$SCRIPT_DIR/../energy-measurement/node-exporter/service.yaml" &> /dev/null
    fi

    # Check for errors creating the service
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create Node Exporter service." >&2
        exit 1
    fi

    # Step 4: Confirm service’s endpoints are pointing to all the DaemonSet pods
    # kubectl get endpoints -n monitoring &> /dev/null
    # This check is commented out because it does not alter the state and we're suppressing output.
    print_banner $GREEN "Power Measurement Framework: Node Exporter Started"
}

deploy_prometheus() {
    # Define the namespace and the directory containing the configuration files
    print_banner $YELLOW "Power Measurement Framework: Prometheus Starting"
    NAMESPACE="monitoring"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    CONFIG_DIR="$SCRIPT_DIR/prometheus"

    # Create the namespace if it doesn't exist
    kubectl get namespace "$NAMESPACE" &> /dev/null || kubectl create namespace "$NAMESPACE" &> /dev/null

    # Deploy Prometheus components
    for FILE in $(ls $CONFIG_DIR/*.yaml); do
        RESOURCE_TYPE=$(cat $FILE | grep 'kind:' | awk '{print $2}')
        RESOURCE_NAME=$(cat $FILE | grep 'name:' | head -1 | awk '{print $2}')

        # Check if the resource already exists
        if kubectl get $RESOURCE_TYPE $RESOURCE_NAME -n $NAMESPACE &> /dev/null; then
            kubectl apply -f $FILE -n $NAMESPACE &> /dev/null
        else
            kubectl create -f $FILE -n $NAMESPACE &> /dev/null
        fi
    done

    print_banner $GREEN "Power Measurement Framework: Prometheus Starting"
}

undeploy_prometheus() {
    print_banner $YELLOW "Power Measurement Framework: Prometheus Stopping"
    NAMESPACE="monitoring"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    CONFIG_DIR="$SCRIPT_DIR/prometheus"

    # Deploy Prometheus components
    for FILE in $(ls $CONFIG_DIR/*.yaml); do
        kubectl delete -f $FILE -n $NAMESPACE &> /dev/null
    done

    # Delete the namespace if it doesn't exist
    kubectl delete namespace "$NAMESPACE" &> /dev/null

    print_banner $GREEN "Power Measurement Framework: Prometheus Stopping"
}


deploy_grafana() {
    print_banner $YELLOW "Power Measurement Framework: Grafana Starting"
    NAMESPACE="monitoring"

    # Create the namespace if it doesn't exist, suppress the output
    kubectl get namespace "$NAMESPACE" &> /dev/null || kubectl create namespace "$NAMESPACE" &> /dev/null

    # Get the path to the directory containing this script, suppress error if realpath is not found
    SCRIPT_DIR=$(dirname "$(realpath "$0" 2>/dev/null)")
    CONFIG_DIR="$SCRIPT_DIR/../Components/grafana"

    # Apply the configuration files to create/update the Grafana deployment and service, suppress the output
    kubectl apply -f "$CONFIG_DIR/grafana-deployment.yaml" -n $NAMESPACE &> /dev/null
    kubectl apply -f "$CONFIG_DIR/grafana-service.yaml" -n $NAMESPACE &> /dev/null

    print_banner $GREEN "Power Measurement Framework: Grafana Started"
}

undeploy_grafana() {
    print_banner $YELLOW "Power Measurement Framework: Grafana Stopping"
    NAMESPACE="monitoring"
    # Get the path to the directory containing this script, suppress error if realpath is not found
    SCRIPT_DIR=$(dirname "$(realpath "$0" 2>/dev/null)")
    CONFIG_DIR="$SCRIPT_DIR/../Components/grafana"

    # Apply the configuration files to create/update the Grafana deployment and service, suppress the output
    kubectl delete -f "$CONFIG_DIR/grafana-deployment.yaml" -n $NAMESPACE &> /dev/null
    kubectl delete -f "$CONFIG_DIR/grafana-service.yaml" -n $NAMESPACE &> /dev/null

    print_banner $GREEN "Power Measurement Framework: Grafana Stopped"

}

# Start Kepler component of Power Measurement Framework
start_kepler() {
    print_banner $YELLOW "Power Measurement Framework: Kepler Starting"

    helm repo add kepler https://sustainable-computing-io.github.io/kepler-helm-chart &> /dev/null
    
    helm install kepler kepler/kepler --namespace kepler-exporter --create-namespace &> /dev/null

    print_banner $GREEN "Power Measurement Framework: Kepler Started"
}

stop_kepler() {
    print_banner $YELLOW "Power Measurement Framework: Kepler Stopping"

    helm delete kepler --namespace kepler-exporter &> /dev/null

    print_banner $GREEN "Power Measurement Framework: Kepler Stopped"    
}

# Start the GLACIATION platform components
power_measurement_framework_start() {
    # Start the Power Measurement Framework components
    display_glaciation_info
    display_power_measurement_info
    echo -e "${CYAN}Initializing Power Measurement Framework...${RESET}"
    deploy_snmp_exporter
    deploy_idrac_exporter
    deploy_node_exporter    
    deploy_prometheus
    deploy_grafana
    start_kepler
}

power_measurement_framework_stop() {
    echo "Stopping the power measurement framework..."
    undeploy_prometheus
    undeploy_grafana
    stop_kepler
}

# Check for the parameter and call the relevant function
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <start|stop>"
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
