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
class ThemeController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateThemeRequest();
    createReq.tenantId = tenantId;
    createReq.name = data.getString("name");
    createReq.description = data.getString("description");
    createReq.mode = jsonEnum!ThemeMode(data, "mode", ThemeMode.light);
    createReq.baseTheme = data.getString("baseTheme");
    createReq.colors = parseColors(data);
    createReq.fonts = parseFonts(data);
    createReq.customCss = data.getString("customCss");
    createReq.isDefault = data.getBoolean("isDefault", false);
    createReq.whitelistedIps = data.getStrings("whitelistedIps");

    auto result = useCase.createTheme(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("id", result.themeId);
    return successResponse("Theme created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto themes = useCase.listThemes(tenantId);
    auto response = Json.emptyObject
      .set("totalResults", themes.length)
      .set("resources", themes);

    return successResponse("Themes retrieved successfully", "OK", 200, response);
  }

  override protected void handleGetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto theme = useCase.getDefaultTheme(tenantId);
      if (theme.isNull) {
        writeApiError(res, 404, "No default theme found");
        return;
      }
      res.writeJsonBody(toJsonValue(theme), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto themeId = precheck.id;
    auto theme = useCase.getTheme(tenantId, themeId);
    if (theme.isNull)
      return errorResponse("Theme not found", 404);

    return successResponse("Theme retrieved successfully", "Retrieved", 200, toJsonValue(theme));

  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto themeId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdateThemeRequest();
    updateReq.tenantId = tenantId;
    updateReq.themeId = themeId;
    updateReq.name = data.getString("name");
    updateReq.description = data.getString("description");
    updateReq.mode = jsonEnum!ThemeMode(data, "mode", ThemeMode.light);
    updateReq.colors = parseColors(data);
    updateReq.fonts = parseFonts(data);
    updateReq.customCss = data.getString("customCss");
    updateReq.isDefault = data.getBoolean("isDefault", false);

    auto result = useCase.updateTheme(updateReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Theme updated successfully", "Updated", 200, Json.emptyObject.set("id", themeId));
    //     writeApiError(res, 404, error);
    //   else
    //     res.writeJsonBody(Json.emptyObject, 200);
    // } catch (Exception e) {
    //   writeApiError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto themeId = precheck.id;
    auto error = useCase.deleteTheme(tenantId, themeId);
    if (error.length > 0)
      writeApiError(res, 400, error);
    else
      res.writeJsonBody(Json.emptyObject, 204);
  }
 catch (Exception e) {
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
