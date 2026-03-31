module uim.platform.identity_authentication.presentation.http.provider_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_providers;
import application.dto;
import domain.entities.content_provider;
import domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class ProviderController
{
    private ManageProvidersUseCase useCase;

    this(ManageProvidersUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/providers", &handleCreate);
        router.get("/api/v1/providers", &handleList);
        router.get("/api/v1/providers/*", &handleGet);
        router.put("/api/v1/providers/*", &handleUpdate);
        router.delete_("/api/v1/providers/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateProviderRequest(
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "name"),
                jsonStr(j, "description"),
                jsonEnum!ProviderType(j, "providerType", ProviderType.local),
                jsonStr(j, "contentEndpointUrl"),
                jsonStr(j, "authToken"),
            );

            auto result = useCase.createProvider(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.providerId);
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
            auto providers = useCase.listProviders(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) providers.length);
            response["resources"] = toJsonArray(providers);
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
            auto providerId = extractIdFromPath(req.requestURI);
            auto provider = useCase.getProvider(providerId);
            if (provider == ContentProvider.init)
            {
                writeApiError(res, 404, "Content provider not found");
                return;
            }
            res.writeJsonBody(toJsonValue(provider), 200);
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
            auto providerId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateProviderRequest(
                providerId,
                jsonStr(j, "name"),
                jsonStr(j, "description"),
                jsonStr(j, "contentEndpointUrl"),
                jsonStr(j, "authToken"),
                jsonBool(j, "active", true),
            );

            auto error = useCase.updateProvider(updateReq);
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
            auto providerId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteProvider(providerId);
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
