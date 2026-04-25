/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemorySkillRepository : TenantRepository!(Skill, SkillId), SkillRepository {


    Skill[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Skill[] findByTechnician(TechnicianId technicianId) {
        return findAll().filter!(e => e.technicianId == technicianId).array;
    }

    Skill[] findByCategory(SkillCategory category) {
        return findAll().filter!(e => e.category == category).array;
    }

}
