/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.dto;

import uim.platform.custom_domain.domain.types;

// --- Generic result ---

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Custom Domain ---

struct CreateCustomDomainRequest {
    string tenantId;
    string id;
    string domainName;
    string organizationId;
    string spaceId;
    string environment;
    string createdBy;
}

struct UpdateCustomDomainRequest {
    string tenantId;
    string id;
    string status;
    string activeCertificateId;
    string tlsConfigurationId;
    bool isShared;
    string sharedWithOrgs;
    bool clientAuthEnabled;
    string modifiedBy;
}

// --- Private Key ---

struct CreatePrivateKeyRequest {
    string tenantId;
    string id;
    string subject;
    string[] domains;
    string algorithm;
    int keySize;
    string createdBy;
}

// --- Certificate ---

struct CreateCertificateRequest {
    string tenantId;
    string id;
    string keyId;
    string certificateType;
    string createdBy;
}

struct UploadCertificateChainRequest {
    string tenantId;
    string id;
    string certificatePem;
}

struct ActivateCertificateRequest {
    string tenantId;
    string id;
    string[] domains;
}

// --- TLS Configuration ---

struct CreateTlsConfigurationRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string minProtocolVersion;
    string maxProtocolVersion;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    string createdBy;
}

struct UpdateTlsConfigurationRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string minProtocolVersion;
    string maxProtocolVersion;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    string modifiedBy;
}

// --- Domain Mapping ---

struct CreateDomainMappingRequest {
    string tenantId;
    string id;
    string customDomainId;
    string standardRoute;
    string customRoute;
    string mappingType;
    string applicationName;
    string organizationId;
    string spaceId;
    string createdBy;
}

// --- Trusted Certificate ---

struct CreateTrustedCertificateRequest {
    string tenantId;
    string id;
    string customDomainId;
    string certificatePem;
    string authMode;
    string createdBy;
}

// --- DNS Record ---

struct CreateDnsRecordRequest {
    string tenantId;
    string id;
    string customDomainId;
    string recordType;
    string hostname;
    string value;
    int ttl;
    string createdBy;
}

struct UpdateDnsRecordRequest {
    string tenantId;
    string id;
    string value;
    int ttl;
    string validationStatus;
}

// --- Dashboard ---

struct RefreshDashboardRequest {
    string tenantId;
}
