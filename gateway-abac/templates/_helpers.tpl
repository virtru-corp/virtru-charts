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
Get the secret name for a specific gateway secret
Usage: {{ include "gateway.secretNameFor" (dict "Values" .Values "secretType" "xHeaderAuth") }}
*/}}
{{- define "gateway.secretNameFor" -}}
{{- $secretType := .secretType -}}
{{- $Values := .Values -}}
{{- if eq $secretType "xHeaderAuth" -}}
{{- if and $Values.existingSecret.name $Values.existingSecret.xHeaderAuthSecretName -}}
{{- $Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" .root -}}
{{- end -}}
{{- else if eq $secretType "saslDownstream" -}}
{{- if and $Values.existingSecret.name $Values.existingSecret.saslDownstreamCredentialsName -}}
{{- $Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" .root -}}
{{- end -}}
{{- else if eq $secretType "saslUpstream" -}}
{{- if and $Values.existingSecret.name $Values.existingSecret.saslUpstreamCredentialsName -}}
{{- $Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" .root -}}
{{- end -}}
{{- else if eq $secretType "abacOidcClient" -}}
{{- if and $Values.existingSecret.name $Values.existingSecret.abacOidcClientSecretName -}}
{{- $Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" .root -}}
{{- end -}}
{{- else if eq $secretType "dkim" -}}
{{- if and $Values.existingSecret.name $Values.existingSecret.dkimPrivateKeyName -}}
{{- $Values.existingSecret.name -}}
{{- else -}}
{{- printf "%s-dkim" (include "gateway.fullname" .root) -}}
{{- end -}}
{{- else -}}
{{- include "gateway.fullname" .root -}}
{{- end -}}
{{- end }}

{{/*
Get the secret name for gateway secrets (legacy - keep for backward compatibility)
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
{{- if and .Values.existingSecret.name .Values.existingSecret.dkimPrivateKeyName -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{- printf "%s-dkim" (include "gateway.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Get the secret name for xHeader Auth Secret
*/}}
{{- define "gateway.xHeaderAuthSecretName" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.xHeaderAuthSecretName -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Get the secret name for SASL Downstream Credentials
*/}}
{{- define "gateway.saslDownstreamCredentialsSecretName" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.saslDownstreamCredentialsName -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Get the secret name for SASL Upstream Credentials
*/}}
{{- define "gateway.saslUpstreamCredentialsSecretName" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.saslUpstreamCredentialsName -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Get the secret name for ABAC OIDC Client Secret
*/}}
{{- define "gateway.abacOidcClientSecretName" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.abacOidcClientSecretName -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{- include "gateway.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Get the key name for xHeader Auth Secret
*/}}
{{- define "gateway.xHeaderAuthSecretKey" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.xHeaderAuthSecretName -}}
{{- .Values.existingSecret.xHeaderAuthSecretName -}}
{{- else -}}
gateway-xheader-auth-secret
{{- end -}}
{{- end }}

{{/*
Get the key name for SASL Downstream Credentials
*/}}
{{- define "gateway.saslDownstreamCredentialsKey" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.saslDownstreamCredentialsName -}}
{{- .Values.existingSecret.saslDownstreamCredentialsName -}}
{{- else -}}
gateway-sasl-auth-downstream
{{- end -}}
{{- end }}

{{/*
Get the key name for SASL Upstream Credentials
*/}}
{{- define "gateway.saslUpstreamCredentialsKey" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.saslUpstreamCredentialsName -}}
{{- .Values.existingSecret.saslUpstreamCredentialsName -}}
{{- else -}}
gateway-sasl-auth-upstream
{{- end -}}
{{- end }}

{{/*
Get the key name for ABAC OIDC Client Secret
*/}}
{{- define "gateway.abacOidcClientSecretKey" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.abacOidcClientSecretName -}}
{{- .Values.existingSecret.abacOidcClientSecretName -}}
{{- else -}}
gateway-abac-oidc-client-secret
{{- end -}}
{{- end }}

{{/*
Get the key name for DKIM Private Key
*/}}
{{- define "gateway.dkimPrivateKeyKey" -}}
{{- if and .Values.existingSecret.name .Values.existingSecret.dkimPrivateKeyName -}}
{{- .Values.existingSecret.dkimPrivateKeyName -}}
{{- else -}}
{{- printf "%s._domainkey.%s.pem" .Values.dkimSelector .Values.primaryMailingDomain -}}
{{- end -}}
{{- end }}
