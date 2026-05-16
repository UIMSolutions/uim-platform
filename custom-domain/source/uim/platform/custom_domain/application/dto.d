/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.dto;
// import uim.platform.custom_domain.domain.types;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

// --- Custom Domain ---

struct CreateCustomDomainRequest {
    TenantId tenantId;
    CertificateId certificateId;
    UserId createdBy;
    
    string domainName;
    OrganizationId organizationId;
    SpaceId spaceId;
    string environment;
}

struct UpdateCustomDomainRequest {
    TenantId tenantId;
    CertificateId certificateId;
    UserId updatedBy;

    string status;
    string activeCertificateId;
    string tlsConfigurationId;
    bool isShared;
    string sharedWithOrgs;
    bool clientAuthEnabled;
}
// --- Private Key ---

struct CreatePrivateKeyRequest {
    TenantId tenantId;
    PrivateKeyId privateKeyId;
    string subject;
    string[] domains;
    string algorithm;
    int keySize;
    UserId createdBy;
}
// --- Certificate ---

struct CreateCertificateRequest {
    TenantId tenantId;
    CertificateId certificateId;
    PrivateKeyId keyId;
    string certificateType;
    UserId createdBy;
}

struct UploadCertificateChainRequest {
    TenantId tenantId;
    CertificateId certificateId;
    string certificatePem;
}

struct ActivateCertificateRequest {
    TenantId tenantId;
    CertificateId certificateId;
    string[] domains;
}
// --- TLS Configuration ---

struct CreateTlsConfigurationRequest {
    TenantId tenantId;
    TlsConfigurationId tlsConfigurationId   ;
    string name;
    string description;
    string minProtocolVersion;
    string maxProtocolVersion;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    UserId createdBy;
}

struct UpdateTlsConfigurationRequest {
    TenantId tenantId;
    TlsConfigurationId tlsConfigurationId;
    string name;
    string description;
    string minProtocolVersion;
    string maxProtocolVersion;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    UserId updatedBy;
}
// --- Domain Mapping ---

struct CreateDomainMappingRequest {
    TenantId tenantId;
    DomainMappingId domainMappingId;
    CustomDomainId customDomainId;
    OrganizationId organizationId;
    SpaceId spaceId;

    string standardRoute;
    string customRoute;
    string mappingType;
    string applicationName;
    UserId createdBy;
}
// --- Trusted Certificate ---

struct CreateTrustedCertificateRequest {
    TenantId tenantId;
    TrustedCertificateId trustedCertificateId;
    CustomDomainId customDomainId;
    string certificatePem;
    string authMode;
    UserId createdBy;
}
// --- DNS Record ---

struct CreateDnsRecordRequest {
    TenantId tenantId;
    DnsRecordId dnsRecordId;
    CustomDomainId customDomainId;
    
    string recordType;
    string hostname;
    string value;
    int ttl;
    UserId createdBy;
}

struct UpdateDnsRecordRequest {
    TenantId tenantId;
    DnsRecordId dnsRecordId;
    string value;
    int ttl;
    string validationStatus;
}
// --- Dashboard ---

struct RefreshDashboardRequest {
    TenantId tenantId;
}
