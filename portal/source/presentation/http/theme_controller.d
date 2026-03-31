module uim.platform.identity_authentication.presentation.http.theme_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_themes;
import application.dto;
import domain.entities.theme;
import domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class ThemeController
{
    private ManageThemesUseCase useCase;

    this(ManageThemesUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/themes", &handleCreate);
        router.get("/api/v1/themes", &handleList);
        router.get("/api/v1/themes/default", &handleGetDefault);
        router.get("/api/v1/themes/*", &handleGet);
        router.put("/api/v1/themes/*", &handleUpdate);
        router.delete_("/api/v1/themes/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateThemeRequest(
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "name"),
                jsonStr(j, "description"),
                jsonEnum!ThemeMode(j, "mode", ThemeMode.light),
                jsonStr(j, "baseTheme"),
                parseColors(j),
                parseFonts(j),
                jsonStr(j, "customCss"),
                jsonBool(j, "isDefault", false),
            );

            auto result = useCase.createTheme(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.themeId);
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
            auto themes = useCase.listThemes(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) themes.length);
            response["resources"] = toJsonArray(themes);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleGetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto theme = useCase.getDefaultTheme(tenantId);
            if (theme == Theme.init)
            {
                writeApiError(res, 404, "No default theme found");
                return;
            }
            res.writeJsonBody(toJsonValue(theme), 200);
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
            auto themeId = extractIdFromPath(req.requestURI);
            auto theme = useCase.getTheme(themeId);
            if (theme == Theme.init)
            {
                writeApiError(res, 404, "Theme not found");
                return;
            }
            res.writeJsonBody(toJsonValue(theme), 200);
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
            auto themeId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateThemeRequest(
                themeId,
                jsonStr(j, "name"),
                jsonStr(j, "description"),
                jsonEnum!ThemeMode(j, "mode", ThemeMode.light),
                parseColors(j),
                parseFonts(j),
                jsonStr(j, "customCss"),
                jsonBool(j, "isDefault", false),
            );

            auto error = useCase.updateTheme(updateReq);
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
            auto themeId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteTheme(themeId);
            if (error.length > 0)
                writeApiError(res, 400, error);
            else
                res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private ThemeColors parseColors(Json j)
    {
        auto colorsJson = "colors" in j;
        if (colorsJson is null || (*colorsJson).type != Json.Type.object)
            return ThemeColors.init;
        auto c = *colorsJson;
        return ThemeColors(
            jsonStr(c, "primary"),
            jsonStr(c, "secondary"),
            jsonStr(c, "accent"),
            jsonStr(c, "background"),
            jsonStr(c, "surface"),
            jsonStr(c, "error"),
            jsonStr(c, "warning"),
            jsonStr(c, "info"),
            jsonStr(c, "success"),
            jsonStr(c, "textPrimary"),
        );
    }

    private ThemeFonts parseFonts(Json j)
    {
        auto fontsJson = "fonts" in j;
        if (fontsJson is null || (*fontsJson).type != Json.Type.object)
            return ThemeFonts.init;
        auto f = *fontsJson;
        return ThemeFonts(
            jsonStr(f, "headingFamily"),
            jsonStr(f, "bodyFamily"),
            jsonStr(f, "baseSizePx"),
            jsonStr(f, "lineHeight"),
        );
    }
}
