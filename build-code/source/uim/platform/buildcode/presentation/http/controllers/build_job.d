/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.build_job;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class BuildJobController : SAPController {
  private ManageBuildJobsUseCase _uc;

  this(ManageBuildJobsUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get ("/api/v1/buildcode/buildjobs",    &listBuildJobs);
    router.post("/api/v1/buildcode/buildjobs",    &triggerBuild);
    router.get ("/api/v1/buildcode/buildjobs/*",  &getBuildJob);
    router.put ("/api/v1/buildcode/buildjobs/*",  &updateStatus);
  }

  private void listBuildJobs(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto pipelineId = req.query.get("pipelineId", "");
    auto projectId  = req.query.get("projectId", "");
    BuildJob[] items;
    if (pipelineId.length > 0)
      items = _uc.listByPipeline(tenantId, pipelineId);
    else if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (j; items) arr ~= j.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void triggerBuild(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    TriggerBuildRequest dto;
    dto.pipelineId  = body_["pipelineId"].get!string("");
    dto.commitSha   = body_["commitSha"].get!string("");
    dto.branch      = body_["branch"].get!string("");
    dto.triggeredBy = body_["triggeredBy"].get!string("api");
    auto result = _uc.trigger(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getBuildJob(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto job      = _uc.getById(tenantId, id);
    if (job.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Build job not found");
    res.writeJsonBody(job.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updateStatus(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto id        = precheck.id;
    auto body_     = req.json;
    auto statusStr = body_["status"].get!string("");
    auto result    = _uc.updateStatus(tenantId, id, statusStr);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
