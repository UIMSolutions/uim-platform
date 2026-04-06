/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface SubstitutionRuleRepository {
    SubstitutionRule findById(SubstitutionRuleId id);
    SubstitutionRule[] findByTenant(TenantId tenantId);
    SubstitutionRule[] findByUser(UserId userId);
    SubstitutionRule[] findBySubstitute(UserId substituteId);
    SubstitutionRule[] findByStatus(SubstitutionStatus status);
    void save(SubstitutionRule entity);
    void update(SubstitutionRule entity);
    void remove(SubstitutionRuleId id);
}
