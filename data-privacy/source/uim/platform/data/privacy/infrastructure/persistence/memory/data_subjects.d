/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.data_subjects;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_subject;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

  DataSubject findByExternalId(string externaltenantId, id tenantId) {
    foreach (s; findAll)
      if (s.externalId == externalId && s.tenantId == tenantId)
        return s;
    return DataSubject.init;
  }

  size_t countByType(TenantId tenantId, DataSubjectType subjectType) {
    return findByType(tenantId, subjectType).length;
  }

  DataSubject[] filterByType(DataSubject[] subjects, DataSubjectType subjectType) {
    return subjects.filter!(s => s.subjectType == subjectType).array;
  }

  DataSubject[] findByType(TenantId tenantId, DataSubjectType subjectType) {
    return filterByType(findByTenant(tenantId), subjectType);
  }
  
  void removeByType(TenantId tenantId, DataSubjectType subjectType) {
    findByType(tenantId, subjectType).each!(entity => remove(entity.id));
  }

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem) {
    return findBySourceSystem(tenantId, sourceSystem).length;
  }

  DataSubject[] filterBySourceSystem(DataSubject[] subjects, string sourceSystem) {
    return subjects.filter!(s => s.sourceSystem == sourceSystem).array;
  }

  DataSubject[] findBySourceSystem(TenantId tenantId, string sourceSystem) {
    return filterBySourceSystem(findByTenant(tenantId), sourceSystem);
  }

  void removeBySourceSystem(TenantId tenantId, string sourceSystem) {
    findBySourceSystem(tenantId, sourceSystem).each!(entity => remove(entity.id));
  }

}
