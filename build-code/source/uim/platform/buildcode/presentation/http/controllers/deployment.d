/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.deployment;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

class DeploymentController : SAPController {
  private ManageDeploymentsUseCase _uc;

  this(ManageDeploymentsUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get ("/api/v1/buildcode/deployments",   &listDeployments);
    router.post("/api/v1/buildcode/deployments",   &createDeployment);
    router.get ("/api/v1/buildcode/deployments/*", &getDeployment);
    router.put ("/api/v1/buildcode/deployments/*", &updateDeploymentStatus);
  }

  private void listDeployments(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto projectId = req.query.get("projectId", "");
    auto envStr    = req.query.get("environment", "");
    Deployment[] items;
    if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else if (envStr.length > 0)
      items = _uc.listByEnvironment(tenantId, envStr);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (d; items) arr ~= d.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createDeployment(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    CreateDeploymentRequest dto;
    dto.projectId         = body_["projectId"].get!string("");
    dto.buildJobId        = body_["buildJobId"].get!string("");
    dto.artifactVersion   = body_["artifactVersion"].get!string("latest");
    dto.targetEnvironment = body_["targetEnvironment"].get!string("cloud-foundry");
    dto.targetOrg         = body_["targetOrg"].get!string("");
    dto.targetSpace       = body_["targetSpace"].get!string("");
    dto.deployedBy        = body_["deployedBy"].get!string("api");
    auto result = _uc.create(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getDeployment(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto d        = _uc.getById(tenantId, id);
    if (d.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Deployment not found");
    res.writeJsonBody(d.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updateDeploymentStatus(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto id        = precheck.id;
    auto body_     = req.json;
    auto statusStr = body_["status"].get!string("");
    auto url       = body_["targetUrl"].get!string("");
    auto result    = _uc.updateStatus(tenantId, id, statusStr, url);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
