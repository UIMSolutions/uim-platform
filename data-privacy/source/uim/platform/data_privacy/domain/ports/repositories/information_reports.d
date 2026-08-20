/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.repositories.information_reports;

// import uim.platform.data_privacy.domain.entities.information_report;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying information reports.
interface IInformationReportRepository : ITenantRepository!(InformationReport, InformationReportId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  InformationReport[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, InformationReportStatus status);
  InformationReport[] findByStatus(TenantId tenantId, InformationReportStatus status);
  void removeByStatus(TenantId tenantId, InformationReportStatus status);

}
