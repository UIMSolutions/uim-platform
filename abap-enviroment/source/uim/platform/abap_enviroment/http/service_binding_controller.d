module uim.platform.abap_enviroment.presentation.http.service_binding;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.abap_enviroment.application.use_cases.manage_service_bindings;
import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.service_binding;
import uim.platform.abap_enviroment.domain.types;
import uim.platform.abap_enviroment.presentation.http.json_utils;

class ServiceBindingController
{
    private ManageServiceBindingsUseCase uc;

    this(ManageServiceBindingsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/service-bindings", &handleCreate);
        router.get("/api/v1/service-bindings", &handleList);
        router.get("/api/v1/service-bindings/*", &handleGetById);
        router.put("/api/v1/service-bindings/*", &handleUpdate);
        router.delete_("/api/v1/service-bindings/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateServiceBindingRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.systemInstanceId = j.getString("systemInstanceId");
            r.serviceDefinitionId = j.getString("serviceDefinitionId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.bindingType = j.getString("bindingType");

            auto result = uc.createBinding(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto systemId = req.headers.get("X-System-Id", "");
            auto bindings = uc.listBindings(systemId);
            auto arr = Json.emptyArray;
            foreach (ref b; bindings)
                arr ~= serializeBinding(b);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) bindings.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto binding = uc.getBinding(id);
            if (binding is null)
            {
                writeError(res, 404, "Service binding not found");
                return;
            }
            res.writeJsonBody(serializeBinding(*binding), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateServiceBindingRequest r;
            r.description = j.getString("description");
            r.status = j.getString("status");

            auto result = uc.updateBinding(id, r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteBinding(id);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("deleted");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeBinding(ref const ServiceBinding b)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(b.id);
        j["tenantId"] = Json(b.tenantId);
        j["systemInstanceId"] = Json(b.systemInstanceId);
        j["serviceDefinitionId"] = Json(b.serviceDefinitionId);
        j["name"] = Json(b.name);
        j["description"] = Json(b.description);
        j["bindingType"] = Json(b.bindingType.to!string);
        j["status"] = Json(b.status.to!string);
        j["serviceUrl"] = Json(b.serviceUrl);
        j["metadataUrl"] = Json(b.metadataUrl);
        j["createdAt"] = Json(b.createdAt);
        j["updatedAt"] = Json(b.updatedAt);

        if (b.endpoints.length > 0)
        {
            auto eps = Json.emptyArray;
            foreach (ref ep; b.endpoints)
            {
                auto ej = Json.emptyObject;
                ej["path"] = Json(ep.path);
                ej["serviceName"] = Json(ep.serviceName);
                ej["serviceVersion"] = Json(ep.serviceVersion);
                ej["requiresAuth"] = Json(ep.requiresAuth);
                eps ~= ej;
            }
            j["endpoints"] = eps;
        }

        return j;
    }
}
