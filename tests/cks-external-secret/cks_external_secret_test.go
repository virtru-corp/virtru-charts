package template_test

import (
	"encoding/json"
	"os"
	"os/exec"
	"reflect"
	"strings"
	"testing"

	esapi "github.com/external-secrets/external-secrets/apis/externalsecrets/v1"
	engine "github.com/external-secrets/external-secrets/runtime/template/v2"
	corev1 "k8s.io/api/core/v1"
	"sigs.k8s.io/yaml"
)

func renderCKSSecret(t *testing.T, excluded []string) esapi.ExternalSecret {
	t.Helper()
	chart := os.Getenv("CKS_CHART_DIR")
	if chart == "" {
		t.Fatal("CKS_CHART_DIR is required")
	}
	settings := []map[string]any{{"name": "cks", "secretsPath": "cks-test", "excludeKeys": excluded, "secretStoreRef": map[string]string{"kind": "ClusterSecretStore", "name": "test"}}}
	values, err := json.Marshal(settings)
	if err != nil {
		t.Fatal(err)
	}
	command := exec.Command("helm", "template", "cks", chart, "--show-only", "templates/external-secret.yaml", "--set-json", "externalAppSecrets="+string(values))
	rendered, err := command.CombinedOutput()
	if err != nil {
		t.Fatalf("helm: %v\n%s", err, rendered)
	}
	var secret esapi.ExternalSecret
	if err := yaml.Unmarshal(rendered, &secret); err != nil {
		t.Fatal(err)
	}
	return secret
}

func TestCKSExternalSecretExclusions(t *testing.T) {
	expected := map[string][]byte{
		"rsa001.pem":           []byte("-----BEGIN PRIVATE KEY-----\nsynthetic-only\n-----END PRIVATE KEY-----\n"),
		"rsa001.pub":           []byte("synthetic-public-key\n"),
		"hmac-auth-token-json": []byte(`[{"value":"a:b"}]`),
		"DSP_DB_PASSWORD":      []byte("false"),
		"numeric":              []byte("1234"),
	}
	for _, tc := range []struct {
		name     string
		excluded []string
		extra    map[string][]byte
	}{
		{"present", []string{"KAS_ROOT_KEY"}, map[string][]byte{"KAS_ROOT_KEY": []byte("synthetic-root")}},
		{"empty", []string{"KAS_ROOT_KEY"}, map[string][]byte{"KAS_ROOT_KEY": []byte("")}},
		{"absent", []string{"KAS_ROOT_KEY"}, nil},
		{"multiple", []string{"KAS_ROOT_KEY", "OTHER_SECRET"}, map[string][]byte{"KAS_ROOT_KEY": []byte("synthetic-root"), "OTHER_SECRET": []byte("synthetic-other")}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			source := map[string][]byte{}
			for key, value := range expected {
				source[key] = value
			}
			for key, value := range tc.extra {
				source[key] = value
			}
			rendered := renderCKSSecret(t, tc.excluded)
			tmpl := rendered.Spec.Target.Template
			if tmpl == nil || tmpl.EngineVersion != esapi.TemplateEngineV2 || tmpl.MergePolicy != esapi.MergePolicyReplace {
				t.Fatal("expected v2/Replace template")
			}
			if len(tmpl.TemplateFrom) != 1 || tmpl.TemplateFrom[0].Literal == nil {
				t.Fatal("expected one literal template")
			}
			target := &corev1.Secret{}
			err := engine.Execute(map[string][]byte{"filter": []byte(*tmpl.TemplateFrom[0].Literal)}, source, esapi.TemplateScopeKeysAndValues, "Data", target)
			if err != nil {
				t.Fatal(err)
			}
			if !reflect.DeepEqual(target.Data, expected) {
				t.Fatalf("filtered data differs: %#v", target.Data)
			}
			if !reflect.DeepEqual(source["KAS_ROOT_KEY"], tc.extra["KAS_ROOT_KEY"]) {
				t.Fatal("provider data was modified")
			}
		})
	}
	for _, excluded := range [][]string{nil, {}} {
		if renderCKSSecret(t, excluded).Spec.Target.Template != nil {
			t.Fatal("no exclusions must preserve the untemplated secret")
		}
	}
}

func TestCKSExternalSecretOriginalBug(t *testing.T) {
	err := engine.Execute(map[string][]byte{"filter": []byte(`{{ omit . "KAS_ROOT_KEY" | toYaml }}`)}, map[string][]byte{"KAS_ROOT_KEY": []byte("synthetic-root")}, esapi.TemplateScopeKeysAndValues, "Data", &corev1.Secret{})
	if err == nil || !strings.Contains(err.Error(), "map[string]interface {}") {
		t.Fatalf("expected original context type error, got %v", err)
	}
}
