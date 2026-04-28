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
    string id;
    string domainName;
    string organizationId;
    string spaceId;
    string environment;
    UserId createdBy;
}

struct UpdateCustomDomainRequest {
    TenantId tenantId;
    string id;
    string status;
    string activeCertificateId;
    string tlsConfigurationId;
    bool isShared;
    string sharedWithOrgs;
    bool clientAuthEnabled;
    UserId modifiedBy;
}

// --- Private Key ---

struct CreatePrivateKeyRequest {
    TenantId tenantId;
    string id;
    string subject;
    string[] domains;
    string algorithm;
    int keySize;
    UserId createdBy;
}

// --- Certificate ---

struct CreateCertificateRequest {
    TenantId tenantId;
    string id;
    string keyId;
    string certificateType;
    UserId createdBy;
}

struct UploadCertificateChainRequest {
    TenantId tenantId;
    string id;
    string certificatePem;
}

struct ActivateCertificateRequest {
    TenantId tenantId;
    string id;
    string[] domains;
}

// --- TLS Configuration ---

struct CreateTlsConfigurationRequest {
    TenantId tenantId;
    string id;
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
    string id;
    string name;
    string description;
    string minProtocolVersion;
    string maxProtocolVersion;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    UserId modifiedBy;
}

// --- Domain Mapping ---

struct CreateDomainMappingRequest {
    TenantId tenantId;
    string id;
    string customDomainId;
    string standardRoute;
    string customRoute;
    string mappingType;
    string applicationName;
    string organizationId;
    string spaceId;
    UserId createdBy;
}

// --- Trusted Certificate ---

struct CreateTrustedCertificateRequest {
    TenantId tenantId;
    string id;
    string customDomainId;
    string certificatePem;
    string authMode;
    UserId createdBy;
}

// --- DNS Record ---

struct CreateDnsRecordRequest {
    TenantId tenantId;
    string id;
    string customDomainId;
    string recordType;
    string hostname;
    string value;
    int ttl;
    UserId createdBy;
}

struct UpdateDnsRecordRequest {
    TenantId tenantId;
    string id;
    string value;
    int ttl;
    string validationStatus;
}

// --- Dashboard ---

struct RefreshDashboardRequest {
    TenantId tenantId;
}
