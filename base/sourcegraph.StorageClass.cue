package base

storageClass: sourcegraph: {
	kind:       "StorageClass"
	apiVersion: "storage.k8s.io/v1"
	metadata: {
		name: "sourcegraph"
		labels: deploy: "sourcegraph-storage"
	}
	provisioner: "kubernetes.io/gce-pd"
	parameters: type: "pd-ssd"
}