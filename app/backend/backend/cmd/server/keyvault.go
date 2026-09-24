// backend/cmd/server/keyvault.go
package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/security/keyvault/azsecrets"
)

const defaultKeyVaultSecretTimeout = 10 * time.Second

// loadDatabasePasswordFromKeyVault retrieves the database password from Azure
// Key Vault using client-secret authentication. This is used only when
// DB_PASSWORD is not already present in the process environment.
func loadDatabasePasswordFromKeyVault() (string, error) {
	var keyVaultURL string // Azure Key Vault URL.
	var secretName string  // Name of the Key Vault secret containing the database password.

	var azureTenantID string     // Azure tenant ID used for service principal authentication.
	var azureClientID string     // Azure client ID used for service principal authentication.
	var azureClientSecret string // Azure client secret used for service principal authentication.

	var azureClientOptions azcore.ClientOptions // Azure Government client options used by the SDK.

	var credentialOptions azidentity.ClientSecretCredentialOptions // Options for client-secret credential creation.
	var credential *azidentity.ClientSecretCredential              // Azure credential used to authenticate to Key Vault.
	var credentialError error                                      // Error returned while creating the Azure credential.

	var secretClientOptions azsecrets.ClientOptions // Options for the Key Vault secrets client.
	var secretClient *azsecrets.Client              // Azure Key Vault secrets client.
	var secretClientError error                     // Error returned while creating the secrets client.

	var secretContext context.Context              // Timeout context for the Key Vault request.
	var cancelSecretContext context.CancelFunc     // Cancels the Key Vault timeout context.
	var secretResponse azsecrets.GetSecretResponse // Response returned by Key Vault.
	var secretError error                          // Error returned while retrieving the secret.

	keyVaultURL = os.Getenv("AZURE_KEY_VAULT_URL")
	secretName = os.Getenv("DB_PASSWORD_SECRET_NAME")
	azureTenantID = os.Getenv("AZURE_TENANT_ID")
	azureClientID = os.Getenv("AZURE_CLIENT_ID")
	azureClientSecret = os.Getenv("AZURE_CLIENT_SECRET")

	if keyVaultURL == "" {
		return "", fmt.Errorf("AZURE_KEY_VAULT_URL is required")
	}

	if secretName == "" {
		return "", fmt.Errorf("DB_PASSWORD_SECRET_NAME is required")
	}

	if azureTenantID == "" || azureClientID == "" || azureClientSecret == "" {
		return "", fmt.Errorf("AZURE_TENANT_ID, AZURE_CLIENT_ID, and AZURE_CLIENT_SECRET are required")
	}

	azureClientOptions = azcore.ClientOptions{
		Cloud: cloud.AzureGovernment,
	}

	credentialOptions = azidentity.ClientSecretCredentialOptions{
		ClientOptions: azureClientOptions,
	}

	credential, credentialError = azidentity.NewClientSecretCredential(
		azureTenantID,
		azureClientID,
		azureClientSecret,
		&credentialOptions,
	)
	if credentialError != nil {
		return "", fmt.Errorf("create Azure credential for Key Vault: %w", credentialError)
	}

	secretClientOptions = azsecrets.ClientOptions{
		ClientOptions: azureClientOptions,
	}

	secretClient, secretClientError = azsecrets.NewClient(
		keyVaultURL,
		credential,
		&secretClientOptions,
	)
	if secretClientError != nil {
		return "", fmt.Errorf("create Key Vault secret client: %w", secretClientError)
	}

	secretContext, cancelSecretContext = context.WithTimeout(
		context.Background(),
		defaultKeyVaultSecretTimeout,
	)
	defer cancelSecretContext()

	secretResponse, secretError = secretClient.GetSecret(secretContext, secretName, "", nil)
	if secretError != nil {
		return "", fmt.Errorf("retrieve database password from Key Vault secret %q: %w", secretName, secretError)
	}

	if secretResponse.Value == nil || *secretResponse.Value == "" {
		return "", fmt.Errorf("key vault secret %q is empty", secretName)
	}

	return *secretResponse.Value, nil
}
