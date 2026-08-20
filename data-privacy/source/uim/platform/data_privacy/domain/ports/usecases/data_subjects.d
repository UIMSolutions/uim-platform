/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.data_subjects;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageDataSubjectsUseCase {

  UsecaseResult createSubject(CreateDataSubjectRequest req);
  DataSubject getSubject(TenantId tenantId, DataSubjectId id);
  DataSubject[] listSubjects(TenantId tenantId);
  DataSubject[] listByType(TenantId tenantId, DataSubjectType subjectType);
  UsecaseResult updateSubject(UpdateDataSubjectRequest req);
  UsecaseResult deleteSubject(TenantId tenantId, DataSubjectId id);
  
}
