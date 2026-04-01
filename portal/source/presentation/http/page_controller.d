module uim.platform.identity_authentication.presentation.http.page;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_pages;
import application.dto;
import domain.entities.page;
import domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class PageController
{
    private ManagePagesUseCase useCase;

    this(ManagePagesUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/pages", &handleCreate);
        router.get("/api/v1/pages", &handleList);
        router.get("/api/v1/pages/*", &handleGet);
        router.put("/api/v1/pages/*", &handleUpdate);
        router.delete_("/api/v1/pages/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreatePageRequest(
                jsonStr(j, "siteId"),
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "title"),
                jsonStr(j, "description"),
                jsonStr(j, "alias"),
                jsonEnum!PageLayout(j, "layout", PageLayout.freeform),
                jsonStrArray(j, "allowedRoleIds"),
                jsonInt(j, "sortOrder"),
                jsonBool(j, "visible", true),
            );

            auto result = useCase.createPage(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.pageId);
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
            auto siteId = jsonStr(Json(req.headers.get("X-Site-Id", "")), "");
            // Use query param for site filter
            auto siteIdParam = req.headers.get("X-Site-Id", "");
            auto pages = useCase.listPages(siteIdParam);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) pages.length);
            response["resources"] = toJsonArray(pages);
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
            auto pageId = extractIdFromPath(req.requestURI);
            auto page = useCase.getPage(pageId);
            if (page == Page.init)
            {
                writeApiError(res, 404, "Page not found");
                return;
            }
            res.writeJsonBody(toJsonValue(page), 200);
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
            auto pageId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdatePageRequest(
                pageId,
                jsonStr(j, "title"),
                jsonStr(j, "description"),
                jsonStr(j, "alias"),
                jsonEnum!PageLayout(j, "layout", PageLayout.freeform),
                jsonStrArray(j, "allowedRoleIds"),
                jsonInt(j, "sortOrder"),
                jsonBool(j, "visible", true),
            );

            auto error = useCase.updatePage(updateReq);
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
            auto pageId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto siteId = j.getString("siteId");
            auto error = useCase.deletePage(pageId, siteId);
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
}
