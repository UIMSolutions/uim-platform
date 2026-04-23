/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.substitution_rules;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface SubstitutionRuleRepository : ITenantRepository!(SubstitutionRule, SubstitutionRuleId) {

    size_t countByUser(UserId userId);
    SubstitutionRule[] findByUser(UserId userId);
    void removeByUser(UserId userId);

    size_t countBySubstitute(UserId substituteId);
    SubstitutionRule[] findBySubstitute(UserId substituteId);
    void removeBySubstitute(UserId substituteId);

    size_t countByStatus(SubstitutionStatus status);
    SubstitutionRule[] findByStatus(SubstitutionStatus status);
    void removeByStatus(SubstitutionStatus status);

}
