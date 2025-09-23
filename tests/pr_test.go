// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const fleetsSolutionsDir = "solutions/fleets-quickstart"
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json

func TestRunFleetsSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: fleetsSolutionsDir,
		Prefix:         "ce-fleets",
		TarIncludePatterns: []string{
			"*.tf",
			fleetsSolutionsDir + "/*.tf",
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

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeFleetsSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: fleetsSolutionsDir,
		Prefix:         "ce-f-u",
		TarIncludePatterns: []string{
			"*.tf",
			fleetsSolutionsDir + "/*.tf",
			"scripts/*.sh",
		},
		ResourceGroup:              resourceGroup,
		Tags:                       []string{"test-schematic"},
		DeleteWorkspaceOnFail:      false,
		WaitJobCompleteMinutes:     60,
		TerraformVersion:           terraformVersion,
		CheckApplyResultForUpgrade: true,
	})
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
