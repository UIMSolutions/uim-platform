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
}
