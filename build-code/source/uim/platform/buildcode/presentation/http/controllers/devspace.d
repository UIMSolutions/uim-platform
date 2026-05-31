/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.devspace;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class DevSpaceController : SAPController {
  private ManageDevSpacesUseCase _uc;

  this(ManageDevSpacesUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get   ("/api/v1/buildcode/devspaces",   &listDevSpaces);
    router.post  ("/api/v1/buildcode/devspaces",   &createDevSpace);
    router.get   ("/api/v1/buildcode/devspaces/*", &getDevSpace);
    router.put   ("/api/v1/buildcode/devspaces/*", &updateDevSpaceStatus);
    router.delete_("/api/v1/buildcode/devspaces/*", &deleteDevSpace);
  }

  private void listDevSpaces(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto projectId = req.query.get("projectId", "");
    DevSpace[] items;
    if (projectId.length > 0)
      items = _uc.listByProject(tenantId, projectId);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (ds; items) arr ~= ds.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createDevSpace(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    CreateDevSpaceRequest dto;
    dto.projectId    = body_["projectId"].get!string("");
    dto.name         = body_["name"].get!string("");
    dto.displayName  = body_["displayName"].get!string(dto.name);
    dto.technicalUser = body_["technicalUser"].get!string("");
    dto.storageGiB   = cast(ushort) body_["storageGiB"].get!long(4);
    dto.ramGiB       = cast(ushort) body_["ramGiB"].get!long(4);
    auto result = _uc.create(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getDevSpace(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto ds       = _uc.getById(tenantId, id);
    if (ds.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Dev space not found");
    res.writeJsonBody(ds.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updateDevSpaceStatus(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto body_    = req.json;
    auto status_  = body_["status"].get!string("");
    auto result   = _uc.setStatus(tenantId, id, status_);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  private void deleteDevSpace(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto result   = _uc.remove(tenantId, id);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.notFound, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.noContent);
  }
}
