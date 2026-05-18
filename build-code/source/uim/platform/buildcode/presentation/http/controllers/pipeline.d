/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.pipeline;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class PipelineController : SAPController {
  private ManagePipelinesUseCase _uc;

  this(ManagePipelinesUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get   ("/api/v1/buildcode/pipelines",   &listPipelines);
    router.post  ("/api/v1/buildcode/pipelines",   &createPipeline);
    router.get   ("/api/v1/buildcode/pipelines/*", &getPipeline);
    router.put   ("/api/v1/buildcode/pipelines/*", &updatePipeline);
    router.delete_("/api/v1/buildcode/pipelines/*", &deletePipeline);
  }

  private void listPipelines(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto projectId = req.query.get("projectId", "");
    Pipeline[] items;
    if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createPipeline(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    CreatePipelineRequest dto;
    dto.projectId      = body_["projectId"].get!string("");
    dto.name           = body_["name"].get!string("");
    dto.description    = body_["description"].get!string("");
    dto.stage          = body_["stage"].get!string("full");
    dto.repositoryUrl  = body_["repositoryUrl"].get!string("");
    dto.branch         = body_["branch"].get!string("main");
    dto.configFilePath = body_["configFilePath"].get!string(".pipeline/config.yml");
    dto.triggerType    = body_["triggerType"].get!string("manual");
    dto.schedule       = body_["schedule"].get!string("");
    auto result = _uc.create(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.error);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getPipeline(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto p        = _uc.getById(tenantId, id);
    if (p.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Pipeline not found");
    res.writeJsonBody(p.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updatePipeline(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto body_    = req.json;
    UpdatePipelineRequest dto;
    dto.description    = body_["description"].get!string("");
    dto.branch         = body_["branch"].get!string("");
    dto.configFilePath = body_["configFilePath"].get!string("");
    dto.isActive       = body_["isActive"].get!bool(true);
    dto.triggerType    = body_["triggerType"].get!string("");
    dto.schedule       = body_["schedule"].get!string("");
    auto result = _uc.update(tenantId, id, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.error);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  private void deletePipeline(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto result   = _uc.remove(tenantId, id);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.notFound, result.error);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.noContent);
  }
}
