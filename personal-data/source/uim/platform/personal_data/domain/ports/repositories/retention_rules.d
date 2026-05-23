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

    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    RetentionRule[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId);

    size_t countByStatus(TenantId tenantId, RetentionRuleStatus status);
    RetentionRule[] findByStatus(TenantId tenantId, RetentionRuleStatus status);
    void removeByStatus(TenantId tenantId, RetentionRuleStatus status);

}
