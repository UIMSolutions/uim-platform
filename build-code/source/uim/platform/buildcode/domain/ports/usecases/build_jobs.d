/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.build_jobs;

import uim.platform.buildcode;
import std.conv     : to;
import std.datetime : Clock, SysTime;

mixin(ShowModule!());

@safe:

interface IManageBuildJobsUseCase {

  CommandResult trigger(TenantId tenantId, TriggerBuildRequest req);
  BuildJob getById(TenantId tenantId, string id);
  BuildJob[] list(TenantId tenantId);
  BuildJob[] listByPipeline(TenantId tenantId, string pipelineId);
  BuildJob[] listByProject(TenantId tenantId, string projectId);
  CommandResult updateStatus(TenantId tenantId, string id, string statusStr);
  
}
