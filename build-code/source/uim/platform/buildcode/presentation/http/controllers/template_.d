/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.controllers.template_;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class TemplateController : SAPController {
  private ManageTemplatesUseCase _uc;

  this(ManageTemplatesUseCase uc) { _uc = uc; }

  override void registerRoutes(URLRouter router) {
    router.get   ("/api/v1/buildcode/templates",   &listTemplates);
    router.post  ("/api/v1/buildcode/templates",   &createTemplate);
    router.get   ("/api/v1/buildcode/templates/*", &getTemplate);
    router.delete_("/api/v1/buildcode/templates/*", &deleteTemplate);
  }

  private void listTemplates(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.headers.get("X-Tenant-Id", "default");
    auto typeStr   = req.query.get("type", "");
    auto builtIn   = req.query.get("builtIn", "");
    ProjectTemplate[] items;
    if (builtIn == "true")
      items = _uc.listBuiltIn(tenantId);
    else if (typeStr.length > 0)
      items = _uc.listByProjectType(tenantId, typeStr);
    else
      items = _uc.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (t; items) arr ~= t.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  private void createTemplate(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto body_    = req.json;
    CreateTemplateRequest dto;
    dto.name        = body_["name"].get!string("");
    dto.displayName = body_["displayName"].get!string(dto.name);
    dto.description = body_["description"].get!string("");
    dto.category    = body_["category"].get!string("");
    dto.projectType = body_["projectType"].get!string("other");
    dto.techStack   = body_["techStack"].get!string("other");
    dto.version_    = body_["version"].get!string("1.0.0");
    dto.author      = body_["author"].get!string("");
    dto.isBuiltIn   = body_["isBuiltIn"].get!bool(false);
    if (body_["parameters"].type == Json.Type.array)
      foreach (p; body_["parameters"]) dto.parameters ~= p.get!string("");
    auto result = _uc.create(tenantId, dto);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.badRequest, result.errorMessage);
    auto j = Json.emptyObject;
    j["id"] = Json(result.id);
    res.writeJsonBody(j, cast(int) HTTPStatus.created);
  }

  private void getTemplate(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto t        = _uc.getById(tenantId, id);
    if (t.isNull) return writeError(res, cast(int) HTTPStatus.notFound, "Template not found");
    res.writeJsonBody(t.toJson(), cast(int) HTTPStatus.ok);
  }

  private void deleteTemplate(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.headers.get("X-Tenant-Id", "default");
    auto id       = extractIdFromPath(req);
    auto result   = _uc.remove(tenantId, id);
    if (!result.success) return writeError(res, cast(int) HTTPStatus.notFound, result.errorMessage);
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.noContent);
  }
}
