{{- define "taggingpdp.gateway.name" -}}
{{- printf "%s-%s" ( include "common.lib.name" . ) "grpc-gwy" }}
{{- end }}

{{- define "taggingpdp.gateway.fullname" -}}
{{- printf "%s-%s" ( include "common.lib.fullname" . ) "grpc-gwy" }}
{{- end }}


{{- define "taggingpdp.gateway.labels" -}}
helm.sh/chart: {{ include "common.lib.chart" . }}
{{ include "taggingpdp.gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "taggingpdp.gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "taggingpdp.gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "taggingpdp.gateway.grpcEndpoint" -}}
{{- printf "%s:%d" ( include "common.lib.fullname" . )  (.Values.service.port | int ) }}
{{- end }}


