/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataSubjectRepository : IRepository!(DataSubject, DataSubjectId) {

    bool existsByEmail(string email);
    DataSubject findByEmail(string email);
    void removeByEmail(string email);

    size_t countByName(string firstName, string lastName);
    DataSubject[] findByName(string firstName, string lastName);
    void removeByName(string firstName, string lastName);

    size_t countByOrganization(string organizationId);
    DataSubject[] findByOrganization(string organizationId);
    void removeByOrganization(string organizationId);
    
}
