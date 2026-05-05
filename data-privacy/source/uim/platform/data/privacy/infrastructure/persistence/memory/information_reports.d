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
class MemoryInformationReportRepository : TenantRepository!(InformationReport, InformationReportId), InformationReportRepository {

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }

  InformationReport[] filterByDataSubject(InformationReport[] records, DataSubjectId subjectId) {
    return records.filter!(s => s.dataSubjectId == subjectId).array;
  }

  InformationReport[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return filterByDataSubject(findByTenant(tenantId), subjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).removeAll;
  } 
  // #endregion ByDataSubject

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, InformationReportStatus status) {
    return findByStatus(tenantId, status).length;
  }

  InformationReport[] filterByStatus(InformationReport[] records, InformationReportStatus status) {
    return records.filter!(s => s.status == status).array;
  }

  InformationReport[] findByStatus(TenantId tenantId, InformationReportStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
    return result;
  }

  void removeByStatus(TenantId tenantId, InformationReportStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }
  // #endregion ByStatus
}
