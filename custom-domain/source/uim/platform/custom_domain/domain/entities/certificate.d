/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.certificate;

import uim.platform.custom_domain.domain.types;

struct CertificateChainEntry {
    string subjectDn;
    string issuerDn;
    string serialNumber;
    long validFrom;
    long validTo;
}

struct Certificate {
    CertificateId id;
    TenantId tenantId;
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
    string createdBy;
    long createdAt;
    long activatedAt;
}
