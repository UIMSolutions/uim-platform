/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.page_template;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.workzone.application.usecases.manage.manage.page_templates;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.page_template;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class PageTemplateController : PageformController {
  private ManagePageTemplatesUseCase useCase;

  this(ManagePageTemplatesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/page-templates", &handleCreate);
    router.get("/api/v1/page-templates", &handleList);
    router.get("/api/v1/page-templates/*", &handleGet);
    router.put("/api/v1/page-templates/*", &handleUpdate);
    router.delete_("/api/v1/page-templates/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreatePageTemplateRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.thumbnailUrl = j.getString("thumbnailUrl");
      r.isDefault = j.getBoolean("isDefault");
      r.isPublic = j.getBoolean("isPublic");

      auto result = useCase.createPageTemplate(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Page template created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto templates = useCase.listPageTemplates(tenantId);
      auto arr = templates.map!(t => t.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", templates.length)
        .set("message", "Page templates retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto t = useCase.getPageTemplate(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Page template not found");
        return;
      }
      res.writeJsonBody(t.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdatePageTemplateRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isDefault = j.getBoolean("isDefault");
      r.isPublic = j.getBoolean("isPublic");

      auto result = useCase.updatePageTemplate(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Page template updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deletePageTemplate(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Page template deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
