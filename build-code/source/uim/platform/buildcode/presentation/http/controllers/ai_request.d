/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.ai_request;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class AIRequestController : SAPController {
  protected ManageAIRequestsUseCase _uc;

  this(ManageAIRequestsUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/buildcode/ai/generate",   &generate);
    router.get ("/api/v1/buildcode/ai/requests",   &listRequests);
    router.get ("/api/v1/buildcode/ai/requests/*", &getRequest);
    router.put ("/api/v1/buildcode/ai/requests/*", &updateStatus);
  }

  private void generate(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto data    = req.json;
    AIGenerateRequest dto;
    dto.projectId      = data.getString("projectId", "");
    dto.requestedBy    = data.getString("requestedBy", "api");
    dto.generationType = data.getString("generationType", "code-fragment");
    dto.prompt         = data.getString("prompt", "");
    dto.targetFilePath = data.getString("targetFilePath", "");
    auto result = _uc.generate(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.accepted);
  }

  private void listRequests(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto projectId = req.query.get("projectId", "");
    auto statusStr = req.query.get("status", "");
    AIRequest[] items;
    if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else if (statusStr.length > 0)
      items = _uc.listByStatus(tenantId, statusStr);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (r; items) arr ~= r.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void getRequest(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto r        = _uc.getById(tenantId, id);
    if (r.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "AI request not found");
    res.writeJsonBody(r.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updateStatus(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId      = req.headers.get("X-Tenant-Id", "default");
    auto id            = precheck.id;
    auto data          = req.json;
    auto statusStr     = data.getString("status", "");
    auto generatedCode = data.getString("generatedCode", "");
    auto errorMsg      = data.getString("errorMessage", "");
    auto result        = _uc.updateStatus(tenantId, id, statusStr, generatedCode, errorMsg);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
