/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.label;


// 
// import uim.platform.management.application.usecases.manage.labels;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class LabelController : PlatformController {
  private ManageLabelsUseCase usecase;

  this(ManageLabelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/labels", &handleCreate);
    router.get("/api/v1/labels", &handleList);
    router.get("/api/v1/labels/*", &handleGet);
    router.put("/api/v1/labels/*", &handleUpdate);
    router.delete_("/api/v1/labels/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateLabelRequest r;
      r.tenantId = tenantId;
      r.resourceType = j.getString("resourceType");
      r.resourceId = j.getString("resourceId");
      r.key = j.getString("key");
      r.values = getStrings(j, "values");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Label created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto resourceType = req.params.get("resourceType");
      auto resourceId = req.params.get("resourceId");
      auto key = req.params.get("key");

      Label[] items;
      if (resourceType.length > 0 && !resourceId.isEmpty)
        items = usecase.listLabels(tenantId, resourceType, resourceId);
      else if (resourceType.length > 0 && key.length > 0)
        items = usecase.listLabelsByKey(tenantId, resourceType, key);

      auto arr = items.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Labels retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto l = usecase.getById(tenantId, id);
      if (l.isNull) {
        writeError(res, 404, "Label not found");
        return;
      }
      res.writeJsonBody(l.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateLabelRequest r;
      r.tenantId = tenantId;
      r.values = getStrings(j, "values");

      auto result = usecase.updateLabel(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = LabelId(extractId(req.requestURI));
      auto result = usecase.deleteLabel(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

