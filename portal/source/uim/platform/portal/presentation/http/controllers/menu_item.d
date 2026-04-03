module uim.platform.portal.presentation.http.controllers.menu_item;

// import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.portal.application.usecases.manage_menu_items;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.entities.menu_item;
import uim.platform.portal.domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class MenuItemController
{
    private ManageMenuItemsUseCase useCase;

    this(ManageMenuItemsUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/menu-items", &handleCreate);
        router.get("/api/v1/menu-items", &handleList);
        router.get("/api/v1/menu-items/*", &handleGet);
        router.put("/api/v1/menu-items/*", &handleUpdate);
        router.delete_("/api/v1/menu-items/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateMenuItemRequest(
                j.getString("siteId"),
                req.headers.get("X-Tenant-Id", ""),
                j.getString("title"),
                j.getString("icon"),
                j.getString("parentId"),
                j.getString("targetPageId"),
                j.getString("targetUrl"),
                jsonEnum!NavigationTarget(j, "navigationTarget", NavigationTarget.inPlace),
                jsonStrArray(j, "allowedRoleIds"),
                jsonInt(j, "sortOrder"),
                j.getBoolean("visible", true),
            );

            auto result = useCase.createMenuItem(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.menuItemId);
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
            auto siteId = req.headers.get("X-Site-Id", "");
            auto items = useCase.listMenuItems(siteId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) items.length);
            response["resources"] = toJsonArray(items);
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
            auto menuItemId = extractIdFromPath(req.requestURI);
            auto item = useCase.getMenuItem(menuItemId);
            if (item == MenuItem.init)
            {
                writeApiError(res, 404, "Menu item not found");
                return;
            }
            res.writeJsonBody(toJsonValue(item), 200);
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
            auto menuItemId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateMenuItemRequest(
                menuItemId,
                j.getString("title"),
                j.getString("icon"),
                j.getString("parentId"),
                j.getString("targetPageId"),
                j.getString("targetUrl"),
                jsonEnum!NavigationTarget(j, "navigationTarget", NavigationTarget.inPlace),
                jsonStrArray(j, "allowedRoleIds"),
                jsonInt(j, "sortOrder"),
                j.getBoolean("visible", true),
            );

            auto error = useCase.updateMenuItem(updateReq);
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
            auto menuItemId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto siteId = j.getString("siteId");
            auto error = useCase.deleteMenuItem(menuItemId, siteId);
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
