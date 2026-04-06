/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.repositories.assessment_repository;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

interface AssessmentRepository {
    Assessment[] findAll();
    Assessment* findById(AssessmentId id);
    Assessment[] findByTenant(TenantId tenantId);
    Assessment[] findByEquipment(EquipmentId equipmentId);
    Assessment[] findByType(AssessmentType assessmentType);
    Assessment[] findByStatus(AssessmentStatus status);
    void save(Assessment assessment);
    void update(Assessment assessment);
    void remove(AssessmentId id);
}
