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

    bool existsByName(string name) {
        return findAll().any!(v => v.name == name);
    }
    RegisteredApplication findByName(string name) {
        foreach (v; findAll)
            if (v.name == name)
                return v;
        return RegisteredApplication.init;
    }

    size_t countByStatus(ApplicationStatus status) {
        return findAll().count!(v => v.status == status);
    }
    RegisteredApplication[] filterByStatus(RegisteredApplication[] applications, ApplicationStatus status, size_t offset = 0, size_t limit = 0) {
        return (limit == 0) 
            ? applications.filter!(v => v.status == status).skip(offset).array
            : applications.filter!(v => v.status == status).skip(offset).take(limit).array;
    }
    RegisteredApplication[] findByStatus(ApplicationStatus status) {
        return filterByStatus(findAll(), status, 0, 0);
    }
    void removeByStatus(ApplicationStatus status) {
        findByStatus(status).each!(v => remove(v.id));
    }

}
