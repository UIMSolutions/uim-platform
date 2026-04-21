/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_subjects;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_subject;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying data subjects.
interface DataSubjectRepository : ITenantRepository!(DataSubject, DataSubjectId) {

  bool existsByExternalId(string externaltenantId, id tenantId);
  DataSubject findByExternalId(string externaltenantId, id tenantId);
  void removeByExternalId(string externaltenantId, id tenantId);
  
  size_t countByType(TenantId tenantId, DataSubjectType subjectType);
  DataSubject[] findByType(TenantId tenantId, DataSubjectType subjectType);
  void removeByType(TenantId tenantId, DataSubjectType subjectType);

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem);
  DataSubject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  void removeBySourceSystem(TenantId tenantId, string sourceSystem);
  
}
