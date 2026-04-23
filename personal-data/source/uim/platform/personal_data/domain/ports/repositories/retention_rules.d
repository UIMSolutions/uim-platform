/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface RetentionRuleRepository : ITenantRepository!(RetentionRule, RetentionRuleId) {

    size_t countByApplication(RegisteredApplicationId applicationId);
    RetentionRule[] findByApplication(RegisteredApplicationId applicationId);
    void removeByApplication(RegisteredApplicationId applicationId);

    size_t countByStatus(RetentionRuleStatus status);
    RetentionRule[] findByStatus(RetentionRuleStatus status);
    void removeByStatus(RetentionRuleStatus status);

}
