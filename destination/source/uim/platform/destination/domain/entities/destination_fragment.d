module uim.platform.xyz.domain.entities.destination_fragment;

import uim.platform.xyz.domain.types;

/// A reusable destination fragment — partial configuration that can be merged into destinations.
struct DestinationFragment
{
    FragmentId id;
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    DestinationLevel level = DestinationLevel.subaccount;

    // Fragment configuration properties (merged into destination at resolution time)
    string url;
    string authenticationType;
    string proxyType;
    string user;
    string password;
    string clientId;
    string clientSecret;
    string tokenServiceUrl;
    string locationId;
    CertificateId keystoreId;
    CertificateId truststoreId;
    string[string] properties;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
