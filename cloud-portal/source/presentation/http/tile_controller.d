module presentation.http.tile_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.use_cases.manage_tiles;
import application.dto;
import domain.entities.tile;
import domain.types;
import presentation.http.json_utils;

class TileController
{
    private ManageTilesUseCase useCase;

    this(ManageTilesUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/tiles", &handleCreate);
        router.get("/api/v1/tiles", &handleList);
        router.get("/api/v1/tiles/search", &handleSearch);
        router.get("/api/v1/tiles/*", &handleGet);
        router.put("/api/v1/tiles/*", &handleUpdate);
        router.delete_("/api/v1/tiles/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateTileRequest(
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "catalogId"),
                jsonStr(j, "title"),
                jsonStr(j, "subtitle"),
                jsonStr(j, "description"),
                jsonStr(j, "icon"),
                jsonStr(j, "info"),
                jsonEnum!TileType(j, "tileType", TileType.static_),
                jsonEnum!AppType(j, "appType", AppType.web),
                jsonStr(j, "url"),
                jsonStr(j, "appId"),
                jsonEnum!NavigationTarget(j, "navigationTarget", NavigationTarget.sameWindow),
                jsonStrArray(j, "keywords"),
                jsonStrArray(j, "allowedRoleIds"),
                parseTileConfig(j),
            );

            auto result = useCase.createTile(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.tileId);
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
            auto tiles = useCase.listTiles(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) tiles.length);
            response["resources"] = toJsonArray(tiles);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto query = req.headers.get("X-Search-Query", "");
            auto tiles = useCase.searchTiles(tenantId, query);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) tiles.length);
            response["resources"] = toJsonArray(tiles);
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
            auto tileId = extractIdFromPath(req.requestURI);
            auto tile = useCase.getTile(tileId);
            if (tile == Tile.init)
            {
                writeApiError(res, 404, "Tile not found");
                return;
            }
            res.writeJsonBody(toJsonValue(tile), 200);
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
            auto tileId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateTileRequest(
                tileId,
                jsonStr(j, "title"),
                jsonStr(j, "subtitle"),
                jsonStr(j, "description"),
                jsonStr(j, "icon"),
                jsonStr(j, "info"),
                jsonEnum!TileType(j, "tileType", TileType.static_),
                jsonEnum!AppType(j, "appType", AppType.web),
                jsonStr(j, "url"),
                jsonStr(j, "appId"),
                jsonEnum!NavigationTarget(j, "navigationTarget", NavigationTarget.sameWindow),
                jsonStrArray(j, "keywords"),
                jsonStrArray(j, "allowedRoleIds"),
                parseTileConfig(j),
            );

            auto error = useCase.updateTile(updateReq);
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
            auto tileId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteTile(tileId);
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

    private TileConfiguration parseTileConfig(Json j)
    {
        import domain.entities.tile : TileConfiguration;
        auto cfgJson = "configuration" in j;
        if (cfgJson is null || (*cfgJson).type != Json.Type.object)
            return TileConfiguration.init;
        auto c = *cfgJson;
        return TileConfiguration(
            jsonStr(c, "serviceUrl"),
            jsonInt(c, "refreshInterval"),
            jsonStr(c, "numberUnit"),
            jsonInt(c, "targetNumber"),
            jsonStr(c, "indicatorColor"),
            jsonStr(c, "sizeBehavior"),
        );
    }
}
