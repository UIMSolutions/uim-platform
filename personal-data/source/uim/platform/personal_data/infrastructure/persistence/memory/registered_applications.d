/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryRegisteredApplicationRepository : RegisteredApplicationRepository {
    private RegisteredApplication[RegisteredApplicationId] store;

    RegisteredApplication findById(RegisteredApplicationId id) {
        if (auto p = id in store) return *p;
        return RegisteredApplication.init;
    }

    RegisteredApplication[] findByTenant(TenantId tenantId) {
        RegisteredApplication[] result;
        foreach (v; store)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    RegisteredApplication findByName(string name) {
        foreach (v; store)
            if (v.name == name) return v;
        return RegisteredApplication.init;
    }

    RegisteredApplication[] findByStatus(ApplicationStatus status) {
        RegisteredApplication[] result;
        foreach (v; store)
            if (v.status == status) result ~= v;
        return result;
    }

    void save(RegisteredApplication entity) { store[entity.id] = entity; }
    void update(RegisteredApplication entity) { store[entity.id] = entity; }
    void remove(RegisteredApplicationId id) { store.remove(id); }
}
