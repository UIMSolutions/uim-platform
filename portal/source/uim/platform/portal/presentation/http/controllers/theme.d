/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.theme;


// import uim.platform.portal.application.usecases.manage.themes;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.theme;
// import uim.platform.portal.domain.types;
import uim.platform.portal;
import uim.platform.portal.application.usecases.manage;

mixin(ShowModule!());

@safe:
class ThemeController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto createReq = CreateThemeRequest(req.headers.get("X-Tenant-Id", ""),
        data.getString("name"), data.getString("description"), jsonEnum!ThemeMode(j,
          "mode", ThemeMode.light), data.getString("baseTheme"), parseColors(j),
        parseFonts(j), data.getString("customCss"), j.getBoolean("isDefault", false),);

      auto result = useCase.createTheme(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.themeId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto themes = useCase.listThemes(tenantId);
      auto response = Json.emptyObject
        .set("totalResults", themes.length)
        .set("resources", themes);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleGetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto themeId = precheck.id;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto themeId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateThemeRequest(themeId, data.getString("name"),
        data.getString("description"), jsonEnum!ThemeMode(j, "mode",
          ThemeMode.light), parseColors(j), parseFonts(j),
        data.getString("customCss"), j.getBoolean("isDefault", false),);

      auto error = useCase.updateTheme(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto themeId = precheck.id;
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
    if (colorsJson.isNull || (colorsJson).type != Json.Type.object)
      return ThemeColors.init;
    auto c = *colorsJson;
    return ThemeColors(c.getString("primary"), c.getString("secondary"),
      c.getString("accent"), c.getString("background"),
      c.getString("surface"), c.getString("error"), c.getString("warning"),
      c.getString("info"), c.getString("success"), c.getString("textPrimary"),);
  }

  private ThemeFonts parseFonts(Json j) {
    auto fontsJson = "fonts" in j;
    if (fontsJson.isNull || (fontsJson).type != Json.Type.object)
      return ThemeFonts.init;
    auto f = *fontsJson;
    return ThemeFonts(getString(f, "headingFamily"), getString(f, "bodyFamily"),
      getString(f, "baseSizePx"), getString(f, "lineHeight"),);
  }
}
