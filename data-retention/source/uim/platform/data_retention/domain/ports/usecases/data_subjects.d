/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageDataSubjectsUseCase { 

    CommandResult createDataSubject(CreateDataSubjectRequest req);
    CommandResult updateDataSubject(UpdateDataSubjectRequest req);
    CommandResult blockDataSubject(TenantId tenantId, DataSubjectId id);
    bool hasDataSubjectById(TenantId tenantId, DataSubjectId id);
    DataSubject getDataSubject(TenantId tenantId, DataSubjectId id);
    DataSubject[] listDataSubjects(TenantId tenantId);
    DataSubject[] listDataSubjects(TenantId tenantId, DataLifecycleStatus status);
    CommandResult deleteDataSubject(TenantId tenantId, DataSubjectId id);

}
