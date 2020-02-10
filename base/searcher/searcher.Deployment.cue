package base

deployment: searcher: {
	metadata: {
		annotations: description: "Backend for text search operations."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "searcher"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 1
			}
			type: "RollingUpdate"
		}
		template: {
			spec: {
				containers: [{
					env: [{
						name:  "SEARCHER_CACHE_SIZE_MB"
						value: "100000"
					}, {
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}]
					image:                    "index.docker.io/sourcegraph/searcher:3.12.6@sha256:97af11ce4b5678680ec80e3693993a88b6228b83dd538f5a749e0f0faa566236"
					terminationMessagePolicy: "FallbackToLogsOnError"
					ports: [{
						containerPort: 3181
						name:          "http"
					}, {
						containerPort: 6060
						name:          "debug"
					}]
					readinessProbe: {
						failureThreshold: 1
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds: 1
					}
					resources: {
						limits: {
							cpu:    "2"
							memory: "2G"
						}
						requests: {
							cpu:    "500m"
							memory: "500M"
						}
					}
					volumeMounts: [{
						mountPath: "/mnt/cache"
						name:      "cache-ssd"
					}]
				}]
				volumes: [{
					emptyDir: {}
					name: "cache-ssd"
				}]
			}
		}
	}
}