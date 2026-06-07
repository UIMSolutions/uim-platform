/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.tile;


// import uim.platform.portal.application.usecases.manage.tiles;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.tile;
// import uim.platform.portal.domain.types;
// .platform.identity.authentication.presentation.http
// import uim.platform.portal.application.usecases.manage;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class TileController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateTileRequest(req.headers.get("X-Tenant-Id", ""),
        data.getString("catalogId"), data.getString("title"), data.getString("subtitle"),
        data.getString("description"), data.getString("icon"), data.getString("info"),
        jsonEnum!TileType(j, "tileType", TileType.static_), jsonEnum!AppType(j, "appType", AppType
          .url),
        data.getString("url"), data.getString("appId"), jsonEnum!NavigationTarget(j,
          "navigationTarget", NavigationTarget.inPlace), getStrings(j,
          "keywords"), data.getStrings("allowedRoleIds"), parseTileConfig(j),);

      auto result = useCase.createTile(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["id"] = Json(result.tileId);
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
      auto tiles = useCase.listTiles(tenantId);
      auto response = Json.emptyObject
      .set("totalResults", tiles.length)
      .set("resources", tiles);
      
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto query = req.headers.get("X-Search-Query", "");
      auto tiles = useCase.searchTiles(tenantId, query);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(tiles.length);
      response["resources"] = toJsonArray(tiles);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto tileId = precheck.id;
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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto tileId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateTileRequest(tileId, data.getString("title"),
        data.getString("subtitle"), data.getString("description"),
        data.getString("icon"), data.getString("info"), jsonEnum!TileType(j,
          "tileType", TileType.static_), jsonEnum!AppType(j, "appType", AppType.url),
        data.getString("url"), data.getString("appId"), jsonEnum!NavigationTarget(j,
          "navigationTarget", NavigationTarget.inPlace), getStrings(j,
          "keywords"), data.getStrings("allowedRoleIds"), parseTileConfig(j),);

      auto error = useCase.updateTile(updateReq);
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
      auto tileId = precheck.id;
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
    if (cfgJson.isNull || (cfgJson).type != Json.Type.object)
      return TileConfiguration.init;
    auto c = *cfgJson;
    return TileConfiguration(c.getString("serviceUrl"), c.getString("serviceRefreshInterval"),
      c.getString("numberUnit"), c.getString("targetNumber"),
      c.getString("indicatorColor"), c.getString("sizeBehavior"),);
  }
}
