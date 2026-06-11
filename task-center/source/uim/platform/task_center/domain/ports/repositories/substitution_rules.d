/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.substitution_rules;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

interface SubstitutionRuleRepository : ITenantRepository!(SubstitutionRule, SubstitutionRuleId) {

    size_t countByUser(TenantId tenantId, UserId userId);
    SubstitutionRule[] findByUser(TenantId tenantId, UserId userId);
    void removeByUser(TenantId tenantId, UserId userId);

    size_t countBySubstitute(TenantId tenantId, UserId substituteId);
    SubstitutionRule[] findBySubstitute(TenantId tenantId, UserId substituteId);
    void removeBySubstitute(TenantId tenantId, UserId substituteId);

    size_t countByStatus(TenantId tenantId, SubstitutionStatus status);
    SubstitutionRule[] findByStatus(TenantId tenantId, SubstitutionStatus status);
    void removeByStatus(TenantId tenantId, SubstitutionStatus status);

}
