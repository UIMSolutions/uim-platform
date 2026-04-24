/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.information_reports;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.information_report;
// import uim.platform.data.privacy.domain.ports.repositories.information_reports;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryInformationReportRepository : InformationReportRepository {
  private InformationReport[] store;

  InformationReport[] findByTenant(TenantId tenantId) {
    InformationReport[] result;
    foreach (s; findAll)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  InformationReport* findById(InformationReportId tenantId, id tenantId) {
    foreach (s; findAll)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  InformationReport[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    InformationReport[] result;
    foreach (s; findByTenant(tenantId))
      if (s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  InformationReport[] findByStatus(TenantId tenantId, InformationReportStatus status) {
    InformationReport[] result;
    foreach (s; findByTenant(tenantId))
      if (s.status == status)
        result ~= s;
    return result;
  }

  void save(InformationReport entity) {
    store ~= entity;
  }

  void update(InformationReport entity) {
    foreach (s; findAll)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(InformationReportId tenantId, id tenantId) {
    InformationReport[] kept;
    foreach (s; findAll)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
