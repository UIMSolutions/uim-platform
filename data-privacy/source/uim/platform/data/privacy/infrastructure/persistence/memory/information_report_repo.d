/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.information_report_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.information_report;
import uim.platform.data.privacy.domain.ports.information_report_repository;

class MemoryInformationReportRepository : InformationReportRepository {
  private InformationReport[] store;

  InformationReport[] findByTenant(TenantId tenantId) {
    InformationReport[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  InformationReport* findById(InformationReportId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  InformationReport[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    InformationReport[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  InformationReport[] findByStatus(TenantId tenantId, InformationReportStatus status) {
    InformationReport[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(InformationReport entity) {
    store ~= entity;
  }

  void update(InformationReport entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(InformationReportId id, TenantId tenantId) {
    InformationReport[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
