{{/*
Expand the name of the chart.
*/}}
{{- define "gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- $topology := required "gateawayTopology is required" .Values.gatewayTopology }}
{{- $gatewayMode := required "gatewayMode is required" .Values.gatewayMode }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-%s-%s" .Release.Name $name $topology $gatewayMode | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gateway.labels" -}}
helm.sh/chart: {{ include "gateway.chart" . }}
{{ include "gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the secret name for gateway secrets
*/}}
{{- define "gateway.secretName" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.name }}
{{- else }}
{{- include "gateway.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get the secret name for DKIM
*/}}
{{- define "gateway.dkimSecretName" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.name }}
{{- else }}
{{- printf "%s-dkim" (include "gateway.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the key name for xHeader Auth Secret
*/}}
{{- define "gateway.xHeaderAuthSecretKey" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.xHeaderAuthSecretName | default "gateway-xheader-auth-secret" }}
{{- else }}
gateway-xheader-auth-secret
{{- end }}
{{- end }}

{{/*
Get the key name for SASL Downstream Credentials
*/}}
{{- define "gateway.saslDownstreamCredentialsKey" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.saslDownstreamCredentialsName | default "gateway-sasl-auth-downstream" }}
{{- else }}
gateway-sasl-auth-downstream
{{- end }}
{{- end }}

{{/*
Get the key name for SASL Upstream Credentials
*/}}
{{- define "gateway.saslUpstreamCredentialsKey" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.saslUpstreamCredentialsName | default "gateway-sasl-auth-upstream" }}
{{- else }}
gateway-sasl-auth-upstream
{{- end }}
{{- end }}

{{/*
Get the key name for ABAC OIDC Client Secret
*/}}
{{- define "gateway.abacOidcClientSecretKey" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.abacOidcClientSecretName | default "gateway-abac-oidc-client-secret" }}
{{- else }}
gateway-abac-oidc-client-secret
{{- end }}
{{- end }}

{{/*
Get the key name for DKIM Private Key
*/}}
{{- define "gateway.dkimPrivateKeyKey" -}}
{{- if .Values.existingSecret.name }}
{{- .Values.existingSecret.dkimPrivateKeyName | default (printf "%s._domainkey.%s.pem" .Values.dkimSelector .Values.primaryMailingDomain) }}
{{- else }}
{{- printf "%s._domainkey.%s.pem" .Values.dkimSelector .Values.primaryMailingDomain }}
{{- end }}
{{- end }}
