/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.skills;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

interface SkillRepository : ITenantRepository!(Skill, SkillId) {

    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId);
    Skill[] findByTechnician(TenantId tenantId, TechnicianId technicianId);
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId);

    size_t countByCategory(TenantId tenantId, SkillCategory category);
    Skill[] findByCategory(TenantId tenantId, SkillCategory category);
    void removeByCategory(TenantId tenantId, SkillCategory category);

}
