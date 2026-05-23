/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryRegisteredApplicationRepository : TenantRepository!(RegisteredApplication, RegisteredApplicationId), RegisteredApplicationRepository {

    bool existsByName(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(v => v.name == name);
    }
    RegisteredApplication findByName(TenantId tenantId, string name) {
        foreach (v; findByTenant(tenantId))
            if (v.name == name)
                return v;
        return RegisteredApplication.init;
    }

    size_t countByStatus(TenantId tenantId, ApplicationStatus status) {
        return findByTenant(tenantId).count!(v => v.status == status);
    }
    RegisteredApplication[] filterByStatus(RegisteredApplication[] applications, ApplicationStatus status, size_t offset = 0, size_t limit = 0) {
        return (limit == 0) 
            ? applications.filter!(v => v.status == status).skip(offset).array
            : applications.filter!(v => v.status == status).skip(offset).take(limit).array;
    }
    RegisteredApplication[] findByStatus(TenantId tenantId, ApplicationStatus status) {
        return filterByStatus(findByTenant(tenantId), status, 0, 0);
    }
    void removeByStatus(TenantId tenantId, ApplicationStatus status) {
        findByStatus(tenantId, status).each!(v => remove(v.id));
    }

}
