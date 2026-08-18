/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.project;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class ProjectController : SAPController {
  protected ManageProjectsUseCase _uc;

  this(ManageProjectsUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get   ("/api/v1/buildcode/projects",   &listProjects);
    router.post  ("/api/v1/buildcode/projects",   &createProject);
    router.get   ("/api/v1/buildcode/projects/*", &getProject);
    router.put   ("/api/v1/buildcode/projects/*", &updateProject);
    router.delete_("/api/v1/buildcode/projects/*", &deleteProject);
  }

  private void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto statusStr = req.query.get("status", "");
    Project[] items;
    if (statusStr.length > 0)
      items = _uc.listByStatus(tenantId, statusStr);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createProject(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto data    = req.json;
    CreateProjectRequest dto;
    dto.name          = data.getString("name", "");
    dto.description   = data.getString("description", "");
    dto.type          = data.getString("type", "other");
    dto.techStack     = data.getString("techStack", "other");
    dto.ownerEmail    = data.getString("ownerEmail", "");
    dto.repositoryUrl = data.getString("repositoryUrl", "");
    dto.defaultBranch = data.getString("defaultBranch", "main");
    if (data["tags"].isArray)
      foreach (t; data["tags"]) dto.tags ~= t.get!string("");
    auto result = _uc.create(tenantId, dto);
    if (!result.success)
      return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getProject(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto p        = _uc.getById(tenantId, id);
    if (p.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Project not found");
    res.writeJsonBody(p.toJson(), cast(int) HTTPStatus.ok);
  }

  private void updateProject(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto data    = req.json;
    UpdateProjectRequest dto;
    dto.description   = data.getString("description", "");
    dto.ownerEmail    = data.getString("ownerEmail", "");
    dto.repositoryUrl = data.getString("repositoryUrl", "");
    dto.defaultBranch = data.getString("defaultBranch", "");
    dto.status        = data.getString("status", "");
    if (data["tags"].isArray)
      foreach (t; data["tags"]) dto.tags ~= t.get!string("");
    auto result = _uc.update(tenantId, id, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  private void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = precheck.id;
    auto result   = _uc.remove(tenantId, id);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.notFound, result.message);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.noContent);
  }
}
