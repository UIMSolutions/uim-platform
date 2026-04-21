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
interface DataSubjectRepository {
  bool existsByTenant(TenantId tenantId);
  DataSubject[] findByTenant(TenantId tenantId);
 
  bool existsById(DataSubjectId tenantId, id tenantId);
  DataSubject findById(DataSubjectId tenantId, id tenantId);

  bool existsByExternalId(string externaltenantId, id tenantId);
  DataSubject findByExternalId(string externaltenantId, id tenantId);
  
  DataSubject[] findByType(TenantId tenantId, DataSubjectType subjectType);
  DataSubject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  
  void save(DataSubject subject);
  void update(DataSubject subject);
  void remove(DataSubjectId tenantId, id tenantId);
}
