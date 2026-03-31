module uim.platform.identity_authentication.presentation.http.translation_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_translations;
import application.dto;
import domain.entities.translation;
import domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class TranslationController
{
    private ManageTranslationsUseCase useCase;

    this(ManageTranslationsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/translations", &handleCreate);
        router.get("/api/v1/translations", &handleList);
        router.get("/api/v1/translations/*", &handleGet);
        router.put("/api/v1/translations/*", &handleUpdate);
        router.delete_("/api/v1/translations/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateTranslationRequest(
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "resourceType"),
                jsonStr(j, "resourceId"),
                jsonStr(j, "fieldName"),
                jsonStr(j, "language"),
                jsonStr(j, "value"),
            );

            auto result = useCase.createTranslation(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.translationId);
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
            auto language = req.headers.get("X-Language", "");
            auto resourceType = req.headers.get("X-Resource-Type", "");
            auto resourceId = req.headers.get("X-Resource-Id", "");

            Translation[] translations;
            if (resourceType.length > 0 && resourceId.length > 0)
                translations = useCase.getTranslationsForResource(resourceType, resourceId, language);
            else
                translations = useCase.listTranslations(tenantId, language);

            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) translations.length);
            response["resources"] = toJsonArray(translations);
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
            auto translationId = extractIdFromPath(req.requestURI);
            auto translation = useCase.getTranslation(translationId);
            if (translation == Translation.init)
            {
                writeApiError(res, 404, "Translation not found");
                return;
            }
            res.writeJsonBody(toJsonValue(translation), 200);
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
            auto translationId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateTranslationRequest(
                translationId,
                jsonStr(j, "value"),
            );

            auto error = useCase.updateTranslation(updateReq);
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
            auto translationId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteTranslation(translationId);
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
