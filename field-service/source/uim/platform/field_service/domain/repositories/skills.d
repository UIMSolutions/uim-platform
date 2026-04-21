/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface SkillRepository {
    bool existsById(SkillId id);
    Skill findById(SkillId id);

    Skill[] findAll();
    Skill[] findByTenant(TenantId tenantId);
    Skill[] findByTechnician(TechnicianId technicianId);
    Skill[] findByCategory(SkillCategory category);

    void save(Skill skill);
    void update(Skill skill);
    void remove(SkillId id);
}
