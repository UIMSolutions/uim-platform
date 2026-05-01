/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository :TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {
    private DataSubject[DataSubjectId] store;

    DataSubject findById(DataSubjectId id) {
        if (auto p = id in store) return *p;
        return DataSubject.init;
    }

    DataSubject[] findByTenant(TenantId tenantId) {
        DataSubject[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    DataSubject findByEmail(string email) {
        foreach (v; findAll)
            if (v.email == email) return v;
        return DataSubject.init;
    }

    DataSubject[] findByName(string firstName, string lastName) {
        DataSubject[] result;
        foreach (v; findAll) {
            bool match = true;
            if (firstName.length > 0 && v.firstName != firstName) match = false;
            if (lastName.length > 0 && v.lastName != lastName) match = false;
            if (match) result ~= v;
        }
        return result;
    }

    DataSubject[] findByOrganization(string organizationId) {
        DataSubject[] result;
        foreach (v; findAll)
            if (v.organizationId == organizationId) result ~= v;
        return result;
    }

    void save(DataSubject entity) { store[entity.id] = entity; }
    void update(DataSubject entity) { store[entity.id] = entity; }
    void remove(DataSubjectId id) { store.removeById(id); }
}
