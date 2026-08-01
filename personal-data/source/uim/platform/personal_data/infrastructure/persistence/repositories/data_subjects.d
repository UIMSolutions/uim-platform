/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.repositories.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

    // #region ByEmail
    bool existsByEmail(TenantId tenantId, string email) {
        return findByTenant(tenantId).any!(v => v.email == email);
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
                remove(v);
                return;
            }
    }
    // #endregion ByEmail

    // #region ByName
    size_t countByName(TenantId tenantId, string firstName, string lastName) {
        return findByName(tenantId, firstName, lastName).length;
    }

    bool validateName(DataSubject subject, string firstName, string lastName) {
        return firstName.length > 0 && lastName.length > 0 && subject.firstName == firstName && subject.lastName == lastName;
    }
    
    DataSubject[] filterByName(DataSubject[] subjects, string firstName, string lastName) {
        return subjects.filter!(v => validateName(v, firstName, lastName)).array;
    }

    DataSubject[] findByName(TenantId tenantId, string firstName, string lastName) {
        return filterByName(findByTenant(tenantId), firstName, lastName);
    }

    void removeByName(TenantId tenantId, string firstName, string lastName) {
        findByName(tenantId, firstName, lastName).each!(v => remove(v));
    }
    // #endregion ByName

    // #region ByOrganization
    size_t countByOrganization(TenantId tenantId, OrganizationId organizationId) {
        return findByOrganization(tenantId, organizationId).length;
    }

    DataSubject[] filterByOrganization(DataSubject[] subjects, OrganizationId organizationId) {
        return subjects.filter!(v => v.organizationId.value == organizationId.value).array;
    }

    DataSubject[] findByOrganization(TenantId tenantId, OrganizationId organizationId) {
        return filterByOrganization(findByTenant(tenantId), organizationId);
    }

    void removeByOrganization(TenantId tenantId, OrganizationId organizationId) {
        findByOrganization(tenantId, organizationId).each!(v => remove(v));
    }
    // #endregion ByOrganization

}
