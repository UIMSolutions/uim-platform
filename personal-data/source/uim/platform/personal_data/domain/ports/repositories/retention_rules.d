/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface RetentionRuleRepository {
    RetentionRule findById(RetentionRuleId id);
    RetentionRule[] findByTenant(TenantId tenantId);
    RetentionRule[] findByApplication(RegisteredApplicationId applicationId);
    RetentionRule[] findByStatus(RetentionRuleStatus status);
    void save(RetentionRule entity);
    void update(RetentionRule entity);
    void remove(RetentionRuleId id);
}
