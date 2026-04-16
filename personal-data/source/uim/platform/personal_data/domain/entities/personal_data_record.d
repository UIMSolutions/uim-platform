/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.personal_data_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct PersonalDataRecord {
    PersonalDataRecordId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    RegisteredApplicationId applicationId;
    string dataCategoryId;
    DataSensitivity sensitivity;
    string fieldName;
    string fieldValue;
    string purposeId;
    string legalBasis;
    string sourceSystem;
    string retentionRuleId;
    string validFrom;
    string validTo;
    bool isAnonymized;
    string createdBy;
    string createdAt;
    string modifiedAt;

    Json toJson() {
        return Json.emptyObject
            .set("id", id)
            .set("dataSubjectId", dataSubjectId)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("dataCategory", dataCategory.to!string)
            .set("sensitivity", sensitivity.to!string)
            .set("fieldName", fieldName)
            .set("fieldValue", fieldValue)
            .set("purposeId", purposeId)
            .set("legalBasis", legalBasis.to!string)
            .set("retentionRuleId", retentionRuleId)
            .set("isAnonymized", isAnonymized)
            .set("createdBy", createdBy)
            .set("createdAt", createdAt);
    }
}
