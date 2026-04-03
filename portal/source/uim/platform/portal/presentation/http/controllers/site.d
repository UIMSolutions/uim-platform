module uim.platform.portal.presentation.http.controllers.site;

// import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.portal.application.usecases.manage_sites;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class SiteController
{
    private ManageSitesUseCase useCase;

    this(ManageSitesUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/sites", &handleCreate);
        router.get("/api/v1/sites", &handleList);
        router.get("/api/v1/sites/*", &handleGet);
        router.put("/api/v1/sites/*", &handleUpdate);
        router.delete_("/api/v1/sites/*", &handleDelete);
        router.post("/api/v1/sites/publish/*", &handlePublish);
        router.post("/api/v1/sites/unpublish/*", &handleUnpublish);
        router.post("/api/v1/sites/archive/*", &handleArchive);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateSiteRequest(
                req.headers.get("X-Tenant-Id", ""),
                j.getString("name"),
                j.getString("description"),
                j.getString("alias"),
                j.getString("themeId"),
                parseSiteSettings(j),
            );

            auto result = useCase.createSite(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.siteId);
                res.writeJsonBody(response, 201);
            }
            else
            {
                writeApiError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto sites = useCase.listSites(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) sites.length);
            response["resources"] = toJsonArray(sites);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto site = useCase.getSite(siteId);
            if (site == Site.init)
            {
                writeApiError(res, 404, "Site not found");
                return;
            }
            res.writeJsonBody(toJsonValue(site), 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateSiteRequest(
                siteId,
                j.getString("name"),
                j.getString("description"),
                j.getString("alias"),
                j.getString("themeId"),
                parseSiteSettings(j),
            );

            auto error = useCase.updateSite(updateReq);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteSite(siteId);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto error = useCase.publishSite(siteId);
            if (error.length > 0)
                writeApiError(res, 400, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleUnpublish(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto error = useCase.unpublishSite(siteId);
            if (error.length > 0)
                writeApiError(res, 400, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleArchive(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto siteId = extractIdFromPath(req.requestURI);
            auto error = useCase.archiveSite(siteId);
            if (error.length > 0)
                writeApiError(res, 400, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private SiteSettings parseSiteSettings(Json j)
    {
        auto settingsJson = "settings" in j;
        if (settingsJson is null || (*settingsJson).type != Json.Type.object)
            return SiteSettings.init;
        auto s = *settingsJson;
        return SiteSettings(
            jsonStr(s, "logoUrl"),
            jsonStr(s, "faviconUrl"),
            jsonStr(s, "footerText"),
            jsonStr(s, "copyrightText"),
            jsonStr(s, "defaultLanguage"),
            jsonStrArray(s, "supportedLanguages"),
            jsonBool(s, "showPersonalization", false),
            jsonBool(s, "showNotifications", false),
            jsonBool(s, "showSearch", true),
            jsonBool(s, "showUserActions", true),
        );
    }
}
