/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.tls_configuration;

import uim.platform.custom_domain.domain.types;

struct CipherSuite {
    string name;
    CipherSuiteStrength strength;
    bool enabled;
}

struct TlsConfiguration {
    TlsConfigurationId id;
    TenantId tenantId;
    string name;
    string description;
    TlsProtocolVersion minProtocolVersion;
    TlsProtocolVersion maxProtocolVersion;
    CipherSuite[] cipherSuites;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
