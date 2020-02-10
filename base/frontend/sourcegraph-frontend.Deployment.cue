package base

deployment: "sourcegraph-frontend": {
	metadata: {
		annotations: description: "Serves the frontend of Sourcegraph via HTTP(S)."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "sourcegraph-frontend"
		strategy: {
			rollingUpdate: {
				maxSurge:       2
				maxUnavailable: 0
			}
			type: "RollingUpdate"
		}
		template: {
			spec: {
				containers: [{
					args: [
						"serve",
					]
					env: [{
						name:  "PGDATABASE"
						value: "sg"
					}, {
						name:  "PGHOST"
						value: "pgsql"
					}, {
						name:  "PGPORT"
						value: "5432"
					}, {
						name:  "PGSSLMODE"
						value: "disable"
					}, {
						name:  "PGUSER"
						value: "sg"
					}, {
						name:  "SRC_GIT_SERVERS"
						value: "gitserver-0.gitserver:3178"
					}, {
						// POD_NAME is used by CACHE_DIR
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						// CACHE_DIR stores larger items we cache. Majority of it is zip
						// archives of repositories at a commit.
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}, {
						name:  "GRAFANA_SERVER_URL"
						value: "http://grafana:30070"
					}]
					image:                    "index.docker.io/sourcegraph/frontend:3.12.6@sha256:d28735deec7626c6819cf631303720572f3f001239ad6ea7a8db850a8606f455"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						initialDelaySeconds: 300
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds:  5
						timeoutSeconds: 5
					}
					name: "frontend"
					ports: [{
						containerPort: 3080
						name:          "http"
					}, {
						containerPort: 3090
						name:          "http-internal"
					}]
					resources: {
						limits: {
							cpu:    "2"
							memory: "4G"
						}
						requests: {
							cpu:    "2"
							memory: "2G"
						}
					}
					volumeMounts: [{
						mountPath: "/mnt/cache"
						name:      "cache-ssd"
					}]
				}]
				serviceAccountName: "sourcegraph-frontend"
				volumes: [{
					emptyDir: {}
					name: "cache-ssd"
				}]
			}
		}
	}
}