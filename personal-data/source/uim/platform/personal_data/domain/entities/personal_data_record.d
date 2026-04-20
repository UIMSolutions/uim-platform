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
    mixin TenantEntity!(PersonalDataRecordId);

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

    Json toJson() const {
        return entityToJson
            .set("dataSubjectId", dataSubjectId.value)
            .set("applicationId", applicationId.value)
            .set("dataCategoryId", dataCategoryId)
            .set("sensitivity", sensitivity.toString())
            .set("fieldName", fieldName)
            .set("fieldValue", fieldValue)
            .set("purposeId", purposeId)
            .set("legalBasis", legalBasis)
            .set("sourceSystem", sourceSystem)
            .set("retentionRuleId", retentionRuleId)
            .set("validFrom", validFrom)
            .set("validTo", validTo)
            .set("isAnonymized", isAnonymized);
    }
}
