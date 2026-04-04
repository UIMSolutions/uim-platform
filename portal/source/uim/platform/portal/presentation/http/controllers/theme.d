/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.theme;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.portal.application.usecases.manage.themes;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.theme;
// import uim.platform.portal.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ThemeController : SAPController {
  private ManageThemesUseCase useCase;

  this(ManageThemesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/themes", &handleCreate);
    router.get("/api/v1/themes", &handleList);
    router.get("/api/v1/themes/default", &handleGetDefault);
    router.get("/api/v1/themes/*", &handleGet);
    router.put("/api/v1/themes/*", &handleUpdate);
    router.delete_("/api/v1/themes/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateThemeRequest(req.headers.get("X-Tenant-Id", ""),
        j.getString("name"), j.getString("description"), jsonEnum!ThemeMode(j,
          "mode", ThemeMode.light), j.getString("baseTheme"), parseColors(j),
        parseFonts(j), j.getString("customCss"), j.getBoolean("isDefault", false),);

      auto result = useCase.createTheme(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["id"] = Json(result.themeId);
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
      auto themes = useCase.listThemes(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long)themes.length);
      response["resources"] = toJsonArray(themes);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleGetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto theme = useCase.getDefaultTheme(tenantId);
      if (theme == Theme.init) {
        writeApiError(res, 404, "No default theme found");
        return;
      }
      res.writeJsonBody(toJsonValue(theme), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto themeId = extractIdFromPath(req.requestURI);
      auto theme = useCase.getTheme(themeId);
      if (theme == Theme.init) {
        writeApiError(res, 404, "Theme not found");
        return;
      }
      res.writeJsonBody(toJsonValue(theme), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto themeId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdateThemeRequest(themeId, j.getString("name"),
        j.getString("description"), jsonEnum!ThemeMode(j, "mode",
          ThemeMode.light), parseColors(j), parseFonts(j),
        j.getString("customCss"), j.getBoolean("isDefault", false),);

      auto error = useCase.updateTheme(updateReq);
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
      auto themeId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteTheme(themeId);
      if (error.length > 0)
        writeApiError(res, 400, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private ThemeColors parseColors(Json j) {
    auto colorsJson = "colors" in j;
    if (colorsJson is null || (*colorsJson).type != Json.Type.object)
      return ThemeColors.init;
    auto c = *colorsJson;
    return ThemeColors(c.getString("primary"), c.getString("secondary"),
      c.getString("accent"), c.getString("background"),
      c.getString("surface"), c.getString("error"), c.getString("warning"),
      c.getString("info"), c.getString("success"), c.getString("textPrimary"),);
  }

  private ThemeFonts parseFonts(Json j) {
    auto fontsJson = "fonts" in j;
    if (fontsJson is null || (*fontsJson).type != Json.Type.object)
      return ThemeFonts.init;
    auto f = *fontsJson;
    return ThemeFonts(jsonStr(f, "headingFamily"), jsonStr(f, "bodyFamily"),
      jsonStr(f, "baseSizePx"), jsonStr(f, "lineHeight"),);
  }
}
