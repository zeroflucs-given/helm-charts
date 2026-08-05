{{/*
Lookup all ConfigMaps with zeroflucs.io/grafana-alerts=true label
Returns a list of parsed config objects
*/}}
{{- define "grafana-alerts.discoverConfigs" -}}
{{- $grafanaNamespace := .Values.grafanaNamespace -}}
{{- $configMaps := (lookup "v1" "ConfigMap" $grafanaNamespace "").items | default list -}}
{{- $alertConfigs := list -}}
{{- range $configMaps -}}
  {{- if eq (index .metadata.labels "zeroflucs.io/grafana-alerts" | default "") "true" -}}
    {{- $configYaml := index .data "config.yaml" -}}
    {{- if $configYaml -}}
      {{- $config := $configYaml | fromYaml -}}
      {{- if $config -}}
        {{- $alertConfigs = append $alertConfigs $config -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $alertConfigs | toJson -}}
{{- end -}}

{{/*
Generate a deterministic UID for an alert rule
*/}}
{{- define "grafana-alerts.uid" -}}
{{- $raw := printf "%s-%s-%s" .namespace .name .alertType -}}
{{- $raw | lower | replace "/" "-" | replace "_" "-" | trunc 40 | trimSuffix "-" -}}
{{- end -}}
