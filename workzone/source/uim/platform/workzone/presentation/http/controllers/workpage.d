/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.workpage;



// import uim.platform.workzone.application.usecases.manage.workpages;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workpage;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class WorkpageController : ManageController {
  private ManageWorkpagesUseCase useCase;

  this(ManageWorkpagesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/workpages", &handleCreate);
    router.get("/api/v1/workpages", &handleList);
    router.get("/api/v1/workpages/*", &handleGet);
    router.put("/api/v1/workpages/*", &handleUpdate);
    router.delete_("/api/v1/workpages/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateWorkpageRequest();
      r.workspaceId = data.getString("workspaceId");
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.sortOrder = data.getInteger("sortOrder");
      r.isDefault = j.getBoolean("isDefault");

      auto result = useCase.createWorkpage(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Workpage created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto workspaceId = req.params.get("workspaceId", "");
      auto pages = useCase.listByWorkspace(tenantId, workspaceId);
      auto arr = pages.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(pages.length))
        .set("message", "Workpages retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto page = useCase.getWorkpage(tenantId, id);
      if (page.isNull) {
        writeError(res, 404, "Page not found");
        return;
      }
      res.writeJsonBody(page.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateWorkpageRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.sortOrder = data.getInteger("sortOrder");
      r.visible = j.getBoolean("visible", true);

      auto result = useCase.updateWorkpage(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Workpage updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteWorkpage(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Workpage deleted");
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializePage(Workpage p) {
  return Json.emptyObject
    .set("id", p.id)
    .set("workspaceId", p.workspaceId)
    .set("tenantId", p.tenantId)
    .set("title", p.title)
    .set("description", p.description)
    .set("sortOrder", p.sortOrder)
    .set("visible", p.visible)
    .set("isDefault", p.isDefault)
    .set("createdAt", p.createdAt)
    .set("updatedAt", p.updatedAt);
}
