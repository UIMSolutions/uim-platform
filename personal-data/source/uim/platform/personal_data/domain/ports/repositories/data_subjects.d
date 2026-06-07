/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subjects;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

interface DataSubjectRepository : ITenantRepository!(DataSubject, DataSubjectId) {

    bool existsByEmail(TenantId tenantId, string email);
    DataSubject findByEmail(TenantId tenantId, string email);
    void removeByEmail(TenantId tenantId, string email);

    size_t countByName(TenantId tenantId, string firstName, string lastName);
    DataSubject[] findByName(TenantId tenantId, string firstName, string lastName);
    void removeByName(TenantId tenantId, string firstName, string lastName);

    size_t countByOrganization(TenantId tenantId, string organizationId);
    DataSubject[] findByOrganization(TenantId tenantId, string organizationId);
    void removeByOrganization(TenantId tenantId, string organizationId);
    
}
