/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.processing_purpose;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct ProcessingPurpose {
    mixin TenantEntity!(ProcessingPurposeId);

    string name;
    string description;
    LegalBasis legalBasis;
    PurposeStatus status;
    string[] dataCategoryIds;
    string[] applicationIds;
    string retentionPeriod;
    string dataProtectionOfficer;
    bool requiresConsent;

    Json toJson() const {
        return Json.entityToJson()
            .set("name", name)
            .set("description", description)
            .set("legalBasis", legalBasis.toString())
            .set("status", status.toString())
            .set("dataCategoryIds", dataCategoryIds)
            .set("applicationIds", applicationIds)
            .set("retentionPeriod", retentionPeriod)
            .set("dataProtectionOfficer", dataProtectionOfficer)
            .set("requiresConsent", requiresConsent);
    }
}
