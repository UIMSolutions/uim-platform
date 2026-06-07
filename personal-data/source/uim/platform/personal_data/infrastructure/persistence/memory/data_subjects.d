/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_subjects;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

    // #region ByEmail
    bool existsByEmail(TenantId tenantId, string email) {
        foreach (v; findByTenant(tenantId))
            if (v.email == email)
                return true;
        return false;
    }

    DataSubject findByEmail(TenantId tenantId, string email) {
        foreach (v; findByTenant(tenantId))
            if (v.email == email)
                return v;
        return DataSubject.init;
    }

    void removeByEmail(TenantId tenantId, string email) {
        foreach (v; findByTenant(tenantId))
            if (v.email == email) {
                store.remove(v.id);
                return;
            }
    }
    // #endregion ByEmail

    // #region ByName
    size_t countByName(TenantId tenantId, string firstName, string lastName) {
        return findByName(tenantId, firstName, lastName).length;
    }

    DataSubject[] filterByName(DataSubject[] subjects, string firstName, string lastName) {
        DataSubject[] result;
        foreach (v; subjects) {
            bool match = true;
            if (firstName.length > 0 && v.firstName != firstName)
                match = false;
            if (lastName.length > 0 && v.lastName != lastName)
                match = false;
            if (match)
                result ~= v;
        }
        return result;
    }

    DataSubject[] findByName(TenantId tenantId, string firstName, string lastName) {
        return filterByName(findByTenant(tenantId), firstName, lastName);
    }
    void removeByName(TenantId tenantId, string firstName, string lastName) {
        findByName(tenantId, firstName, lastName).each!(v => store.remove(v.id));
    }
    // #endregion ByName

    // #region ByOrganization
    size_t countByOrganization(TenantId tenantId, string organizationId) {
        return findByOrganization(tenantId, organizationId).length;
    }

    DataSubject[] filterByOrganization(DataSubject[] subjects, string organizationId) {
        return subjects.filter!(v => v.organizationId == organizationId).array;
    }

    DataSubject[] findByOrganization(TenantId tenantId, string organizationId) {
        return filterByOrganization(findByTenant(tenantId), organizationId);
    }

    void removeByOrganization(TenantId tenantId, string organizationId) {
        findByOrganization(tenantId, organizationId).each!(v => store.remove(v.id));
    }
    // #endregion ByOrganization

}
