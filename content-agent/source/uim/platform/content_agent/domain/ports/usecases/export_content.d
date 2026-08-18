/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.export_content;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Application service for exporting content packages.
interface IExportContentUseCase {

  CommandResult startExport(StartExportRequest req);
  ExportJob getExportJob(TenantId tenantId, ExportJobId id);
  ExportJob[] listExportJobs(TenantId tenantId);
  ExportJob[] listByPackage(TenantId tenantId, ContentPackageId packageId);

}
