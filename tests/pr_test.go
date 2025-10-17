// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const fleetsSolutionsDir = "solutions/fleets-quickstart"
const fullyConfigurableSolutionsDir = "solutions/fully-configurable"
const quickstartSolutionsDir = "solutions/basic-quickstart"
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json

func setupOptions(t *testing.T, prefix string, terraformDir string) *testschematic.TestSchematicOptions {
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: terraformDir,
		Prefix:         prefix,
		TarIncludePatterns: []string{
			"*.tf",
			terraformDir + "/*.tf",
			"scripts/*.sh",
		},
		ResourceGroup:          resourceGroup,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		TerraformVersion:       terraformVersion,
	})
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	return options
}

func TestRunFleetsSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "ce-fleets", fleetsSolutionsDir)
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeFleetsSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "ce-f-u", fleetsSolutionsDir)
	options.CheckApplyResultForUpgrade = false
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestRunFullyConfigurableSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "ce-fcfg", fullyConfigurableSolutionsDir)
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeFullyConfigurableSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "ce-fcfg-u", fullyConfigurableSolutionsDir)
	options.CheckApplyResultForUpgrade = false
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestAddonDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "ce-ad",
		ResourceGroup: resourceGroup,
		QuietMode:     false, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-landing-zone-code-engine",
		"fully-configurable",
		map[string]interface{}{
			"region": "us-south",
		},
	)

	// Disable target / route creation to prevent hitting quota in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
			Enabled: core.BoolPtr(true),
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cloud_logs": false,
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}

func TestRunQuickstartSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "ce-qs", quickstartSolutionsDir)
	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.app.ibm_code_engine_app.ce_app",
		},
	}
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeQuickstartSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "ce-qs", quickstartSolutionsDir)
	options.CheckApplyResultForUpgrade = false
	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.app.ibm_code_engine_app.ce_app",
		},
	}
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}
