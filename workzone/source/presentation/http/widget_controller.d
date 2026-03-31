module uim.platform.identity_authentication.presentation.http.widget;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_widgets;
import application.dto;
import domain.types;
import domain.entities.widget;
import uim.platform.identity_authentication.presentation.http.json_utils;

class WidgetController
{
    private ManageWidgetsUseCase useCase;

    this(ManageWidgetsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/widgets", &handleCreate);
        router.get("/api/v1/widgets", &handleList);
        router.get("/api/v1/widgets/*", &handleGet);
        router.put("/api/v1/widgets/*", &handleUpdate);
        router.delete_("/api/v1/widgets/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateWidgetRequest();
            r.pageId = jsonStr(j, "pageId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.title = jsonStr(j, "title");
            r.cardId = jsonStr(j, "cardId");
            r.appId = jsonStr(j, "appId");
            r.row = jsonInt(j, "row");
            r.col = jsonInt(j, "col");
            r.sortOrder = jsonInt(j, "sortOrder");

            auto sStr = jsonStr(j, "size");
            if (sStr == "small") r.size = WidgetSize.small;
            else if (sStr == "large") r.size = WidgetSize.large;
            else if (sStr == "fullWidth") r.size = WidgetSize.fullWidth;
            else r.size = WidgetSize.medium;

            r.config = parseWidgetConfig(j);

            auto result = useCase.createWidget(r);
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
            auto pageId = req.params.get("pageId", "");
            auto widgets = useCase.listByPage(pageId, tenantId);
            auto arr = Json.emptyArray;
            foreach (ref w; widgets)
                arr ~= serializeWidget(w);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) widgets.length);
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
            auto w = useCase.getWidget(id, tenantId);
            if (w is null)
            {
                writeError(res, 404, "Widget not found");
                return;
            }
            res.writeJsonBody(serializeWidget(*w), 200);
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
            auto r = UpdateWidgetRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.title = jsonStr(j, "title");
            r.row = jsonInt(j, "row");
            r.col = jsonInt(j, "col");
            r.sortOrder = jsonInt(j, "sortOrder");
            r.visible = jsonBool(j, "visible", true);
            r.config = parseWidgetConfig(j);

            auto sStr = jsonStr(j, "size");
            if (sStr == "small") r.size = WidgetSize.small;
            else if (sStr == "large") r.size = WidgetSize.large;
            else if (sStr == "fullWidth") r.size = WidgetSize.fullWidth;
            else r.size = WidgetSize.medium;

            auto result = useCase.updateWidget(r);
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
            useCase.deleteWidget(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private WidgetConfig parseWidgetConfig(Json j)
{
    import domain.entities.widget : WidgetConfig;
    WidgetConfig cfg;
    auto v = "config" in j;
    if (v !is null && (*v).type == Json.Type.object)
    {
        auto c = *v;
        cfg.customTitle = jsonStr(c, "customTitle");
        cfg.maxItems = jsonInt(c, "maxItems");
        cfg.refreshIntervalSec = jsonInt(c, "refreshIntervalSec");
        cfg.filterExpression = jsonStr(c, "filterExpression");
    }
    return cfg;
}

private Json serializeWidget(ref Widget w)
{
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(w.id);
    j["pageId"] = Json(w.pageId);
    j["tenantId"] = Json(w.tenantId);
    j["title"] = Json(w.title);
    j["cardId"] = Json(w.cardId);
    j["appId"] = Json(w.appId);
    j["size"] = Json(w.size.to!string);
    j["row"] = Json(w.row);
    j["col"] = Json(w.col);
    j["sortOrder"] = Json(w.sortOrder);
    j["visible"] = Json(w.visible);
    j["createdAt"] = Json(w.createdAt);
    j["updatedAt"] = Json(w.updatedAt);

    auto cfg = Json.emptyObject;
    cfg["customTitle"] = Json(w.config.customTitle);
    cfg["maxItems"] = Json(w.config.maxItems);
    cfg["refreshIntervalSec"] = Json(w.config.refreshIntervalSec);
    cfg["filterExpression"] = Json(w.config.filterExpression);
    j["config"] = cfg;

    return j;
}
