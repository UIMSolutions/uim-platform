/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.skills;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemorySkillRepository : SkillRepository {
    private Skill[] store;

    bool existsById(SkillId id) {
        return store.any!(e => e.id == id);
    }

    Skill findById(SkillId id) {
        foreach (e; store)
            if (e.id == id)
                return e;
        return Skill.init; // or throw an exception
    }

    Skill[] findAll() {
        return store;
    }

    Skill[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Skill[] findByTechnician(TechnicianId technicianId) {
        return store.filter!(e => e.technicianId == technicianId).array;
    }

    Skill[] findByCategory(SkillCategory category) {
        return store.filter!(e => e.category == category).array;
    }

    void save(Skill skill) {
        store ~= skill;
    }

    void update(Skill skill) {
        foreach (e; store)
            if (e.id == skill.id) {
                e = skill;
                return;
            }
    }

    void remove(SkillId id) {
        import std.algorithm : remove;

        store = store.remove!(e => e.id == id);
    }
}
