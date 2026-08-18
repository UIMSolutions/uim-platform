/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageDataSubjectsUseCase { 

    UsecaseResult createDataSubject(CreateDataSubjectRequest r);
    DataSubject getDataSubject(TenantId tenantId, DataSubjectId id);
    DataSubject[] listDataSubjects(TenantId tenantId);
    DataSubject[] searchDataSubjectsByName(TenantId tenantId, string firstName, string lastName);
    DataSubject findDataSubjectByEmail(TenantId tenantId, string email);
    UsecaseResult updateDataSubject(UpdateDataSubjectRequest r);
    UsecaseResult blockDataSubject(TenantId tenantId, DataSubjectId id);
    UsecaseResult eraseDataSubject(TenantId tenantId, DataSubjectId id);
    UsecaseResult deleteDataSubject(TenantId tenantId, DataSubjectId id);

}
