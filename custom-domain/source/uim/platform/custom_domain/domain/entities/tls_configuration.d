/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.tls_configuration;
// import uim.platform.custom_domain.domain.types;
import uim.platform.custom_domain;

// mixin(ShowModule!());

@safe:
struct CipherSuite {
    string name;
    CipherSuiteStrength strength;
    bool enabled;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("strength", strength.to!string)
            .set("enabled", enabled);
    }
}

struct TlsConfiguration {
    mixin TenantEntity!TlsConfigurationId;

    string name;
    string description;
    TlsProtocolVersion minProtocolVersion;
    TlsProtocolVersion maxProtocolVersion;
    CipherSuite[] cipherSuites;
    bool http2Enabled;
    bool hstsEnabled;
    long hstsMaxAge;
    bool hstsIncludeSubDomains;

    CustomDomainId domainId; // TODO: This should be a reference to the CustomDomain entity, but for simplicity we just store the ID here.  

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("minProtocolVersion", minProtocolVersion.to!string)
            .set("maxProtocolVersion", maxProtocolVersion.to!string)
            .set("cipherSuites", cipherSuites.map!(cs => cs.toJson()).array.toJson)
            .set("http2Enabled", http2Enabled)
            .set("hstsEnabled", hstsEnabled)
            .set("hstsMaxAge", hstsMaxAge)
            .set("hstsIncludeSubDomains", hstsIncludeSubDomains);
    }
}
