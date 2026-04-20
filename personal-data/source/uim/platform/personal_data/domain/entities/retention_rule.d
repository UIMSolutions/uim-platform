/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.retention_rule;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct RetentionRule {
    mixin TenantEntity!(RetentionRuleId);

    string name;
    string description;
    RetentionRuleStatus status;
    int retentionPeriod;
    RetentionPeriodUnit periodUnit;
    string[] dataCategoryIds;
    string[] applicationIds;
    string[] purposeIds;
    bool autoDelete;
    bool notifyBeforeExpiry;
    int notifyDaysBefore;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status)
            .set("retentionPeriod", retentionPeriod)
            .set("periodUnit", periodUnit)
            .set("dataCategoryIds", dataCategoryIds)
            .set("applicationIds", applicationIds)
            .set("purposeIds", purposeIds)
            .set("autoDelete", autoDelete)
            .set("notifyBeforeExpiry", notifyBeforeExpiry)
            .set("notifyDaysBefore", notifyDaysBefore);

        return j;
    }
}
