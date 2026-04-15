/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataSubjectRepository {
    bool existsById(DataSubjectId id);
    DataSubject findById(DataSubjectId id);

    DataSubject[] findByTenant(TenantId tenantId);
    DataSubject findByEmail(string email);
    DataSubject[] findByName(string firstName, string lastName);
    DataSubject[] findByOrganization(string organizationId);
    
    void save(DataSubject entity);
    void update(DataSubject entity);
    void remove(DataSubjectId id);
}
