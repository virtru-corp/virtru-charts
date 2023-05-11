{{/*
Create a pull secret list:
- creates list from image.pullSecrets if defined
- creates list from global.imagePullSecrets if defined
- creates list from imageCredentials if defined and non empty
- otherwise is blank
*/}}
{{- define "sharepoint.imagePullSecrets" }}
{{- if .Values.image.pullSecrets }}
{{- with .Values.image.pullSecrets }}
imagePullSecrets:
    {{- toYaml . | nindent 8 }}
{{- end }}
{{- else if .Values.global.imagePullSecrets }}
{{- with .Values.global.imagePullSecrets }}
imagePullSecrets:
    {{- toYaml . | nindent 8 }}
{{- end }}
{{- else if and ( .Values.imageCredentials ) ( gt (len .Values.imageCredentials ) 0 ) }}
imagePullSecrets:
{{- range $v := .Values.imageCredentials }}
    {{- with $ }}
    - name: {{ include "common.lib.name" . }}-{{ $v.name }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Istio Ingress Gateway name
*/}}
{{- define "sharepoint.istio.gateway" }}
{{- if .Values.ingress.istio.existingGateway }}
{{- printf "%s" .Values.ingress.istio.existingGateway }}
{{- else }}
{{- printf "%s-gateway" ( include "common.lib.fullname" . ) }}
{{- end }}
{{- end }}

