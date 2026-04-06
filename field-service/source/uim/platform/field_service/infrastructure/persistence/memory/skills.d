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

    Skill[] findAll() { return store; }

    Skill* findById(SkillId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Skill[] findByTenant(TenantId tenantId) {
        Skill[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Skill[] findByTechnician(TechnicianId technicianId) {
        Skill[] result;
        foreach (ref e; store)
            if (e.technicianId == technicianId) result ~= e;
        return result;
    }

    Skill[] findByCategory(SkillCategory category) {
        Skill[] result;
        foreach (ref e; store)
            if (e.category == category) result ~= e;
        return result;
    }

    void save(Skill skill) { store ~= skill; }

    void update(Skill skill) {
        foreach (ref e; store)
            if (e.id == skill.id) { e = skill; return; }
    }

    void remove(SkillId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
