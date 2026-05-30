/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.site;


// import uim.platform.portal.application.usecases.manage.sites;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

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
    router.post("/api/v1/sites/publish/*", &handlePublish);
    router.post("/api/v1/sites/unpublish/*", &handleUnpublish);
    router.post("/api/v1/sites/archive/*", &handleArchive);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateSiteRequest(req.headers.get("X-Tenant-Id", ""),
        data.getString("name"), data.getString("description"),
        data.getString("alias"), data.getString("themeId"), parseSiteSettings(j),);

      auto result = useCase.createSite(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
        .set("id", result.siteId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto sites = useCase.listSites(tenantId);
      auto response = Json.emptyObject
      .set("totalResults", sites.length)
      .set("resources", sites);
      
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = precheck.id;
      auto site = useCase.getSite(siteId);
      if (site == Site.init) {
        writeApiError(res, 404, "Site not found");
        return;
      }
      res.writeJsonBody(toJsonValue(site), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto siteId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateSiteRequest(siteId, data.getString("name"), data.getString("description"),
        data.getString("alias"), data.getString("themeId"), parseSiteSettings(j),);

      auto error = useCase.updateSite(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto siteId = precheck.id;
      auto error = useCase.deleteSite(siteId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  protected void handlelish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = precheck.id;
      auto error = useCase.publishSite(siteId);
      if (error.length > 0)
        writeApiError(res, 400, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  protected void handleUnpublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = precheck.id;
      auto error = useCase.unpublishSite(siteId);
      if (error.length > 0)
        writeApiError(res, 400, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  protected void handleArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = precheck.id;
      auto error = useCase.archiveSite(siteId);
      if (error.length > 0)
        writeApiError(res, 400, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private SiteSettings parseSiteSettings(Json j) {
    auto settingsJson = "settings" in j;
    if (settingsJson.isNull || (settingsJson).type != Json.Type.object)
      return SiteSettings.init;
    auto s = *settingsJson;
    return SiteSettings(getString(s, "logoUrl"), getString(s, "faviconUrl"),
      getString(s, "footerText"), getString(s, "copyrightText"), getString(s, "defaultLanguage"), getStrings(s,
        "supportedLanguages"), getBoolean(s, "showPersonalization", false), getBoolean(s,
        "showNotifications", false), getBoolean(s, "showSearch", true),
      getBoolean(s, "showUserActions", true),);
  }
}
