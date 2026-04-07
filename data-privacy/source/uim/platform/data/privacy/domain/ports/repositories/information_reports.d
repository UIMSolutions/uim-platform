/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.information_reports;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.information_report;

/// Port for persisting and querying information reports.
interface InformationReportRepository {
  bool existsTenant(TenantId tenantId);
  InformationReport[] findByTenant(TenantId tenantId);
 
  bool existsId(InformationReportId id, TenantId tenantId);
  InformationReport findById(InformationReportId id, TenantId tenantId);

  InformationReport[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  InformationReport[] findByStatus(TenantId tenantId, InformationReportStatus status);

  void save(InformationReport report);
  void update(InformationReport report);
  void remove(InformationReportId id, TenantId tenantId);
}
