module application.dto;

import domain.types;

/// --- Command result ---

struct CommandResult
{
    bool success;
    string id;
    string error;
}

/// --- Destination DTOs ---

struct CreateDestinationRequest
{
    TenantId tenantId;
    SubaccountId subaccountId;
    ServiceInstanceId serviceInstanceId;
    string name;
    string description;
    string destinationType;         // "http", "rfc", "mail", "ldap"
    string url;
    string authenticationType;      // "NoAuthentication", "BasicAuthentication", "OAuth2ClientCredentials", etc.
    string proxyType;               // "Internet", "OnPremise", "PrivateLink"
    string level;                   // "subaccount", "serviceInstance"

    // HTTP-specific
    string urlPath;
    string httpMethod;

    // Auth fields
    string user;
    string password;
    string clientId;
    string clientSecret;
    string tokenServiceUrl;
    string tokenServiceUser;
    string tokenServicePassword;
    string audience;
    string systemUser;
    string samlAudience;
    string nameIdFormat;
    string authnContextClassRef;

    // Certificate references
    string keystoreId;
    string keystorePassword;
    string truststoreId;

    // On-premise
    string locationId;
    string sccVirtualHost;
    int sccVirtualPort;

    // Custom properties
    string[string] properties;

    // Fragment references
    string[] fragmentIds;

    string createdBy;
}

struct UpdateDestinationRequest
{
    string description;
    string url;
    string authenticationType;
    string proxyType;
    string user;
    string password;
    string clientId;
    string clientSecret;
    string tokenServiceUrl;
    string tokenServiceUser;
    string tokenServicePassword;
    string audience;
    string keystoreId;
    string keystorePassword;
    string truststoreId;
    string locationId;
    string sccVirtualHost;
    int sccVirtualPort;
    string status;                  // "active", "inactive"
    string[string] properties;
    string[] fragmentIds;
}

/// --- Certificate DTOs ---

struct UploadCertificateRequest
{
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    string certificateType;         // "keystore", "truststore"
    string format_;                 // "p12", "jks", "pem", "pfx"
    string content;                 // base64-encoded
    string password;
    string subject;
    string issuer;
    string serialNumber;
    long validFrom;
    long validTo;
    string uploadedBy;
}

struct UpdateCertificateRequest
{
    string description;
    string content;
    string password;
    long validFrom;
    long validTo;
}

/// --- Destination Fragment DTOs ---

struct CreateFragmentRequest
{
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    string level;                   // "subaccount", "serviceInstance"
    string url;
    string authenticationType;
    string proxyType;
    string user;
    string password;
    string clientId;
    string clientSecret;
    string tokenServiceUrl;
    string locationId;
    string keystoreId;
    string truststoreId;
    string[string] properties;
    string createdBy;
}

struct UpdateFragmentRequest
{
    string description;
    string url;
    string authenticationType;
    string proxyType;
    string user;
    string password;
    string clientId;
    string clientSecret;
    string tokenServiceUrl;
    string locationId;
    string keystoreId;
    string truststoreId;
    string[string] properties;
}

/// --- Find Destination DTO ---

struct FindDestinationRequest
{
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string headerProvider;          // "subscriber", "provider"
}

/// --- Destination Lookup Result DTO ---

struct DestinationLookupResponse
{
    bool found;
    string destinationName;
    string url;
    string authenticationType;
    string proxyType;
    string destinationType;
    string[string] properties;
    AuthTokenDto[] authTokens;
    CertificateDto[] certificates;
    string[] appliedFragments;
    string error;
}

struct AuthTokenDto
{
    string type_;
    string value_;
    long expiresAt;
    string httpHeaderSuggestion;
}

struct CertificateDto
{
    string name;
    string type_;
    string format_;
    string status;
}
