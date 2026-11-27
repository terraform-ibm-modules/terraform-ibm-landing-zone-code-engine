// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const fleetsSolutionsDir = "solutions/fleets-quickstart"
const fullyConfigurableSolutionsDir = "solutions/fully-configurable"
const quickstartSolutionsDir = "solutions/basic-quickstart"
const terraformVersion = "terraform_v1.12.2" // This should match the version in the ibm_catalog.json

var permanentResources map[string]interface{}

var sharedInfoSvc *cloudinfo.CloudInfoService

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	sharedInfoSvc, err = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	if err != nil {
		log.Fatal(err)
	}

	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, terraformDir string) *testschematic.TestSchematicOptions {
	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	// Programmatically determine region to use based on availability
	region, _ := testhelper.GetBestVpcRegion(val, "../common-dev-assets/common-go-assets/cloudinfo-region-vpc-gen2-prefs.yaml", "eu-de")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: terraformDir,
		Prefix:         prefix,
		Region:         region,
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
		{Name: "region", Value: options.Region, DataType: "string"},
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
	// expected replace: code-engine build module (>= v4.9.10) hashes its bundled install-binaries.sh, which only runs a local-exec CLI install
	options.IgnoreDestroys = testhelper.Exemptions{
		List: []string{
			"module.build.terraform_data.install_required_binaries[0]",
		},
	}
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}
