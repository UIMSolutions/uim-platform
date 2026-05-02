/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.custom_domain;

// import uim.platform.custom_domain.domain.types;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
struct CustomDomain {
    mixin TenantEntity!(CustomDomainId);

    string domainName;
    string organizationId;
    string spaceId;
    DomainStatus status;
    DomainEnvironment environment;
    string activeCertificateId;
    string tlsConfigurationId;
    bool isShared;
    string sharedWithOrgs;
    bool clientAuthEnabled;

    Json toJson() const {
        return entityToJson
            .set("domainName", domainName)
            .set("organizationId", organizationId)
            .set("spaceId", spaceId)
            .set("status", status.toString())
            .set("environment", environment.toString())
            .set("activeCertificateId", activeCertificateId)
            .set("tlsConfigurationId", tlsConfigurationId)
            .set("isShared", isShared)
            .set("sharedWithOrgs", sharedWithOrgs)
            .set("clientAuthEnabled", clientAuthEnabled);
    }
}
