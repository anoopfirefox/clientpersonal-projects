import subprocess
import sys

def mend_scan(kubeconfig_path):
    command = f"HTTPS_PROXY='localhost:8888' kubectl get pods --all-namespaces --output json --kubeconfig={kubeconfig_path} | jq -r '.items[].spec.containers[].image' | sort -u"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    output, _ = process.communicate()

    if process.returncode == 0:
        images = [line.strip() for line in output.split('\n') if line.strip()]

        components_to_scan = ["kubernetes-csi", "fluxcd", "jetstack", "external-dns", "appscode/kubed", "velero", "vouch-proxy", "ingress-nginx"]
        pod_images_to_scan = [image for image in images if any(component in image for component in components_to_scan)]

        with open("PodImagesToScan.txt", "w") as file:
            file.write("\n".join(pod_images_to_scan))

        # Download and install Mend CLI
        subprocess.run(["curl", "-L", "https://downloads.mend.io/cli/linux_amd64/mend", "-o", "mend"])
        subprocess.run(["chmod", "+x", "mend"])
        subprocess.run(["sudo", "mv", "mend", "/usr/local/bin/"])

        for image in pod_images_to_scan:
            result = subprocess.run(["docker", "pull", image])
            if result.returncode != 0:
                print(f"Error pulling image {image}")
                continue

            print(f"Scanning {image}")
            result = subprocess.run(["mend", "image", "-s", "abc//XYZ//Container-Scan-Results", image])
            if result.returncode != 0:
                print(f"Error scanning image {image}")
    else:
        print("Error fetching images")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python mend_scan.py <kubeconfig_path>")
        sys.exit(1)

    kubeconfig_path = sys.argv[1]
    mend_scan(kubeconfig_path)
