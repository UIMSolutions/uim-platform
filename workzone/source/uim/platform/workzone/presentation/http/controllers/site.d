/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.site;



// import uim.platform.workzone.application.usecases.manage.sites;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.site;
// import uim.platform.identity.authentication.presentation.http;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class SiteController : ManageController {
  private ManageSitesUseCase useCase;

  this(ManageSitesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/sites", &handleCreate);
    router.get("/api/v1/sites", &handleList);
    router.get("/api/v1/sites/*", &handleGet);
    router.put("/api/v1/sites/*", &handleUpdate);
    router.delete_("/api/v1/sites/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateSiteRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.alias_ = j.getString("alias");
      r.themeId = j.getString("themeId");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = useCase.createSite(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Site created");

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
      auto tenantId = req.getTenantId;
      auto sites = useCase.listSites(tenantId);
      auto arr = sites.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(sites.length))
        .set("message", "Sites retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto s = useCase.getSite(tenantId, id);
      if (s.isNull) {
        writeError(res, 404, "Site not found");
        return;
      }
      res.writeJsonBody(s.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = UpdateSiteRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.themeId = j.getString("themeId");

      auto result = useCase.updateSite(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteSite(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
