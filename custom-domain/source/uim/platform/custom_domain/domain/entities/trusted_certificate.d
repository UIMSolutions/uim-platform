/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.trusted_certificate;

import uim.platform.custom_domain.domain.types;

struct TrustedCertificate {
    mixin TenantEntity!(TrustedCertificateId);

    string customDomainId;
    string subjectDn;
    string issuerDn;
    string serialNumber;
    string certificatePem;
    string fingerprint;
    TrustedCertificateStatus status;
    ClientAuthMode authMode;
    long validFrom;
    long validTo;

    Json toJson() const {
        auto j = entityToJson
            .set("customDomainId", customDomainId)
            .set("subjectDn", subjectDn)
            .set("issuerDn", issuerDn)
            .set("serialNumber", serialNumber)
            .set("certificatePem", certificatePem)
            .set("fingerprint", fingerprint)
            .set("status", status.to!string)
            .set("authMode", authMode.to!string)
            .set("validFrom", validFrom)
            .set("validTo", validTo);

        return j;
    }
}
