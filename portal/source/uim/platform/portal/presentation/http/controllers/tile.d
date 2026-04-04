/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.tile;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.portal.application.usecases.manage.tiles;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.tile;
// import uim.platform.portal.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class TileController : SAPController {
  private ManageTilesUseCase useCase;

  this(ManageTilesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/tiles", &handleCreate);
    router.get("/api/v1/tiles", &handleList);
    router.get("/api/v1/tiles/search", &handleSearch);
    router.get("/api/v1/tiles/*", &handleGet);
    router.put("/api/v1/tiles/*", &handleUpdate);
    router.delete_("/api/v1/tiles/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateTileRequest(req.headers.get("X-Tenant-Id", ""),
        j.getString("catalogId"), j.getString("title"), j.getString("subtitle"),
        j.getString("description"), j.getString("icon"), j.getString("info"),
        jsonEnum!TileType(j, "tileType", TileType.static_), jsonEnum!AppType(j, "appType", AppType
          .url),
        j.getString("url"), j.getString("appId"), jsonEnum!NavigationTarget(j,
          "navigationTarget", NavigationTarget.inPlace), jsonStrArray(j,
          "keywords"), jsonStrArray(j, "allowedRoleIds"), parseTileConfig(j),);

      auto result = useCase.createTile(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["id"] = Json(result.tileId);
        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto tiles = useCase.listTiles(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long)tiles.length);
      response["resources"] = toJsonArray(tiles);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto query = req.headers.get("X-Search-Query", "");
      auto tiles = useCase.searchTiles(tenantId, query);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long)tiles.length);
      response["resources"] = toJsonArray(tiles);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tileId = extractIdFromPath(req.requestURI);
      auto tile = useCase.getTile(tileId);
      if (tile == Tile.init) {
        writeApiError(res, 404, "Tile not found");
        return;
      }
      res.writeJsonBody(toJsonValue(tile), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tileId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdateTileRequest(tileId, j.getString("title"),
        j.getString("subtitle"), j.getString("description"),
        j.getString("icon"), j.getString("info"), jsonEnum!TileType(j,
          "tileType", TileType.static_), jsonEnum!AppType(j, "appType", AppType.url),
        j.getString("url"), j.getString("appId"), jsonEnum!NavigationTarget(j,
          "navigationTarget", NavigationTarget.inPlace), jsonStrArray(j,
          "keywords"), jsonStrArray(j, "allowedRoleIds"), parseTileConfig(j),);

      auto error = useCase.updateTile(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tileId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteTile(tileId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private TileConfiguration parseTileConfig(Json j) {
    import uim.platform.portal.domain.entities.tile : TileConfiguration;

    auto cfgJson = "configuration" in j;
    if (cfgJson is null || (*cfgJson).type != Json.Type.object)
      return TileConfiguration.init;
    auto c = *cfgJson;
    return TileConfiguration(c.getString("serviceUrl"), c.getString("serviceRefreshInterval"),
      c.getString("numberUnit"), c.getString("targetNumber"),
      c.getString("indicatorColor"), c.getString("sizeBehavior"),);
  }
}
