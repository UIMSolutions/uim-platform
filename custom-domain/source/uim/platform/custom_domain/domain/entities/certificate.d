/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.certificate;

// import uim.platform.custom_domain.domain.types;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
struct CertificateChainEntry {
    string subjectDn;
    string issuerDn;
    string serialNumber;
    long validFrom;
    long validTo;

    Json toJson() const {
        return Json.emptyObject
            .set("subjectDn", subjectDn)
            .set("issuerDn", issuerDn)
            .set("serialNumber", serialNumber)
            .set("validFrom", validFrom)
            .set("validTo", validTo);
    }

}

struct Certificate {
    mixin TenantEntity!(CertificateId);

    string keyId;
    CertificateType type;
    CertificateStatus status;
    string subjectDn;
    string issuerDn;
    string serialNumber;
    string[] subjectAlternativeNames;
    string certificatePem;
    CertificateChainEntry[] chain;
    string fingerprint;
    long validFrom;
    long validTo;
    string[] activatedDomains;
    long activatedAt;

    Json toJson() const {
        auto j = entityToJson
            .set("keyId", keyId)
            .set("type", type.to!string)
            .set("status", status.to!string)
            .set("subjectDn", subjectDn)
            .set("issuerDn", issuerDn)
            .set("serialNumber", serialNumber)
            .set("subjectAlternativeNames", subjectAlternativeNames)
            .set("certificatePem", certificatePem)
            .set("chain", chain.map!(entry => entry.toJson()))        
            .set("fingerprint", fingerprint)
            .set("validFrom", validFrom)
            .set("validTo", validTo)
            .set("activatedDomains", activatedDomains)
            .set("activatedAt", activatedAt);

        return j;
    }
}
