/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

    // #region ByEmail
    bool existsByEmail(string email) {
        foreach (v; findAll)
            if (v.email == email) return true;
        return false;
    }
    DataSubject findByEmail(string email) {
        foreach (v; findAll)
            if (v.email == email) return v;
        return DataSubject.init;
    }
    void removeByEmail(string email) {
        foreach (v; findAll)
            if (v.email == email) {
                store.remove(v.id);
                return;
            }
    }
    // #endregion ByEmail

    // #region ByName
    size_t countByName(string firstName, string lastName) {
        return findByName(firstName, lastName).length;
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
    size_t countByOrganization(string organizationId) {
        return findByOrganization(organizationId).length;
    }
    // #endregion ByName

    // #region ByOrganization
    size_t countByOrganization(string organizationId) {
        return findByOrganization(organizationId).length;
    }
    DataSubject[] findByOrganization(string organizationId) {
        DataSubject[] result;
        foreach (v; findAll)
            if (v.organizationId == organizationId) result ~= v;
        return result;
    }
    void removeByOrganization(string organizationId) {
        findByOrganization(organizationId).each!(v => store.remove(v.id));
    }
    // #endregion ByOrganization

}
