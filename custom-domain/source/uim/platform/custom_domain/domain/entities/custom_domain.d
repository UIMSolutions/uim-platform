/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.custom_domain;

import uim.platform.custom_domain.domain.types;

struct CustomDomain {
    CustomDomainId id;
    TenantId tenantId;
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
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
