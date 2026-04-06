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
    ProcessingPurposeId id;
    TenantId tenantId;
    string name;
    string description;
    LegalBasis legalBasis;
    PurposeStatus status;
    string[] dataCategoryIds;
    string[] applicationIds;
    string retentionPeriod;
    string dataProtectionOfficer;
    bool requiresConsent;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
