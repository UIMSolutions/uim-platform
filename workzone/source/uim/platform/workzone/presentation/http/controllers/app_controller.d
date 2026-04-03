/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.app_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage_apps;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.app_registration;
import uim.platform.identity_authentication.presentation.http.json_utils;

class AppController
{
    private ManageAppsUseCase useCase;

    this(ManageAppsUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/apps", &handleCreate);
        router.get("/api/v1/apps", &handleList);
        router.get("/api/v1/apps/*", &handleGet);
        router.put("/api/v1/apps/*", &handleUpdate);
        router.delete_("/api/v1/apps/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateAppRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.launchUrl = j.getString("launchUrl");
            r.icon = j.getString("icon");
            r.vendor = j.getString("vendor");
            r.version_ = j.getString("version");
            r.supportedPlatforms = jsonStrArray(j, "supportedPlatforms");
            r.tags = jsonStrArray(j, "tags");
            r.appConfig = parseAppConfig(j);

            auto result = useCase.createApp(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto apps = useCase.listApps(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref a; apps)
                arr ~= serializeApp(a);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) apps.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto app = useCase.getApp(id, tenantId);
            if (app is null)
            {
                writeError(res, 404, "App not found");
                return;
            }
            res.writeJsonBody(serializeApp(*app), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = UpdateAppRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.launchUrl = j.getString("launchUrl");
            r.icon = j.getString("icon");
            r.appConfig = parseAppConfig(j);

            auto sStr = j.getString("status");
            if (sStr == "inactive") r.status = AppStatus.inactive;
            else if (sStr == "deprecated") r.status = AppStatus.deprecated_;
            else r.status = AppStatus.active;

            auto result = useCase.updateApp(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deleteApp(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private AppConfig parseAppConfig(Json j)
{
    import uim.platform.workzone.domain.entities.app_registration : AppConfig;
    AppConfig cfg;
    auto v = "appConfig" in j;
    if (v !is null && (*v).type == Json.Type.object)
    {
        auto c = *v;
        cfg.authType = c.getString("authType");
        cfg.authEndpoint = c.getString("authEndpoint");
        cfg.enableSso = jsonBool(c, "enableSso");
        cfg.sapSystemAlias = c.getString("sapSystemAlias");
        cfg.oDataServiceUrl = c.getString("oDataServiceUrl");
        cfg.componentId = c.getString("componentId");
    }
    return cfg;
}

private Json serializeApp(ref AppRegistration a)
{
    // import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["name"] = Json(a.name);
    j["description"] = Json(a.description);
    j["launchUrl"] = Json(a.launchUrl);
    j["icon"] = Json(a.icon);
    j["vendor"] = Json(a.vendor);
    j["version"] = Json(a.version_);
    j["status"] = Json(a.status.to!string);
    j["createdAt"] = Json(a.createdAt);
    j["updatedAt"] = Json(a.updatedAt);

    auto platforms = Json.emptyArray;
    foreach (ref p; a.supportedPlatforms)
        platforms ~= Json(p);
    j["supportedPlatforms"] = platforms;

    auto tags = Json.emptyArray;
    foreach (ref t; a.tags)
        tags ~= Json(t);
    j["tags"] = tags;

    auto cfg = Json.emptyObject;
    cfg["authType"] = Json(a.appConfig.authType);
    cfg["enableSso"] = Json(a.appConfig.enableSso);
    cfg["sapSystemAlias"] = Json(a.appConfig.sapSystemAlias);
    cfg["componentId"] = Json(a.appConfig.componentId);
    j["appConfig"] = cfg;

    return j;
}
