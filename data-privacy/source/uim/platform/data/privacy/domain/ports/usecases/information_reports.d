/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.information_reports;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageInformationReportsUseCase { 

  UsecaseResult createReport(CreateInformationReportRequest req);
  InformationReport getReport(TenantId tenantId, InformationReportId reportId);
  InformationReport[] listReports(TenantId tenantId);
  InformationReport[] listReports(TenantId tenantId, DataSubjectId subjectId);
  UsecaseResult updateReportStatus(UpdateInformationReportStatusRequest req);
  UsecaseResult deleteReport(TenantId tenantId, InformationReportId reportId);

}
