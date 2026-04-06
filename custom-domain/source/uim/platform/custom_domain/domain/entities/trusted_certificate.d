/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.trusted_certificate;

import uim.platform.custom_domain.domain.types;

struct TrustedCertificate {
    TrustedCertificateId id;
    TenantId tenantId;
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
    string createdBy;
    long createdAt;
}
