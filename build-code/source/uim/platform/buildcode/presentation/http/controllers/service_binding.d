/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.service_binding;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class ServiceBindingController : SAPController {
  private ManageServiceBindingsUseCase _uc;

  this(ManageServiceBindingsUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get   ("/api/v1/buildcode/servicebindings",   &listBindings);
    router.post  ("/api/v1/buildcode/servicebindings",   &createBinding);
    router.get   ("/api/v1/buildcode/servicebindings/*", &getBinding);
    router.delete_("/api/v1/buildcode/servicebindings/*", &deleteBinding);
  }

  private void listBindings(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto projectId = req.query.get("projectId", "");
    ServiceBinding[] items;
    if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (sb; items) arr ~= sb.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createBinding(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    CreateServiceBindingRequest dto;
    dto.projectId    = body_["projectId"].get!string("");
    dto.serviceName  = body_["serviceName"].get!string("");
    dto.servicePlan  = body_["servicePlan"].get!string("");
    dto.bindingLabel = body_["bindingLabel"].get!string("");
    dto.instanceId   = body_["instanceId"].get!string("");
    auto result = _uc.create(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getBinding(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto sb       = _uc.getById(tenantId, id);
    if (sb.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Service binding not found");
    res.writeJsonBody(sb.toJson(), cast(int) HTTPStatus.ok);
  }

  private void deleteBinding(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto result   = _uc.remove(tenantId, id);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.notFound, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.noContent);
  }
}
