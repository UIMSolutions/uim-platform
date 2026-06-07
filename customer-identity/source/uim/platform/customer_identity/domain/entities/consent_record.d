/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.consent_record;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct ConsentRecord {
    mixin TenantEntity!(ConsentRecordId);

    CustomerId customerId;
    ConsentType consentType;
    string purpose;
    LegalBasis legalBasis;
    bool granted;
    long grantedAt;
    long revokedAt;
    string ipAddress;
    string userAgent;
    string version_;
    string locale;

    Json toJson() const {
        return entityToJson
            .set("customerId", customerId.value)
            .set("consentType", consentType.to!string)
            .set("purpose", purpose)
            .set("legalBasis", legalBasis.to!string)
            .set("granted", granted)
            .set("grantedAt", grantedAt)
            .set("revokedAt", revokedAt)
            .set("ipAddress", ipAddress)
            .set("userAgent", userAgent)
            .set("version", version_)
            .set("locale", locale);
    }
}
