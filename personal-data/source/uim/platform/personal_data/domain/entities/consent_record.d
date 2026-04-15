/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.consent_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct ConsentRecord {
    ConsentRecordId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    ProcessingPurposeId purposeId;
    ConsentStatus status;
    string consentText;
    string consentVersion;
    string givenAt;
    string withdrawnAt;
    string expiresAt;
    string ipAddress;
    string userAgent;
    string source;
    string createdBy;
    string createdAt;
    string modifiedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("dataSubjectId", dataSubjectId)
            .set("tenantId", tenantId)
            .set("purposeId", purposeId)
            .set("status", status.to!string)
            .set("consentText", consentText)
            .set("consentVersion", consentVersion)
            .set("givenAt", givenAt)
            .set("withdrawnAt", withdrawnAt)
            .set("expiresAt", expiresAt)
            .set("source", source)
            .set("createdBy", createdBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
