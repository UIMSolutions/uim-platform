module domain.entities.destination;

import domain.types;

/// A destination configuration — defines how to connect to a remote system.
struct Destination
{
    DestinationId id;
    TenantId tenantId;
    SubaccountId subaccountId;
    ServiceInstanceId serviceInstanceId;
    string name;
    string description;
    DestinationType destinationType = DestinationType.http;
    string url;
    AuthenticationType authenticationType = AuthenticationType.noAuthentication;
    ProxyType proxyType = ProxyType.internet;
    DestinationLevel level = DestinationLevel.subaccount;
    DestinationStatus status = DestinationStatus.active;

    // HTTP-specific
    string urlPath;
    string httpMethod;

    // Authentication details
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
    CertificateId keystoreId;
    string keystorePassword;
    CertificateId truststoreId;

    // On-premise / Cloud Connector
    string locationId;
    string sccVirtualHost;
    ushort sccVirtualPort;

    // Custom properties
    string[string] properties;

    // Fragment references
    FragmentId[] fragmentIds;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
