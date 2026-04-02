module presentation.http.service_binding;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_service_bindings;
import application.dto;
import domain.entities.service_binding;
import domain.types;
import presentation.http.json_utils;

class ServiceBindingController
{
    private ManageServiceBindingsUseCase uc;

    this(ManageServiceBindingsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
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
            r.serviceInstanceId = j.getString("serviceInstanceId");
            r.namespaceId = j.getString("namespaceId");
            r.environmentId = j.getString("environmentId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.secretName = j.getString("secretName");
            r.secretNamespace = j.getString("secretNamespace");
            r.parametersJson = j.getString("parameters");
            r.labels = jsonStrMap(j, "labels");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.create(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto nsId = req.params.get("namespaceId");
            auto instId = req.params.get("serviceInstanceId");

            ServiceBinding[] items;
            if (instId.length > 0)
                items = uc.listByServiceInstance(instId);
            else if (nsId.length > 0)
                items = uc.listByNamespace(nsId);
            else
                items = [];

            auto arr = Json.emptyArray;
            foreach (ref b; items)
                arr ~= serializeBinding(b);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto b = uc.getBinding(id);
            if (b.id.length == 0) { writeError(res, 404, "Service binding not found"); return; }
            res.writeJsonBody(serializeBinding(b), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateServiceBindingRequest r;
            r.description = j.getString("description");
            r.secretName = j.getString("secretName");
            r.parametersJson = j.getString("parameters");
            r.labels = jsonStrMap(j, "labels");

            auto result = uc.updateBinding(id, r);
            if (result.success) res.writeJsonBody(Json.emptyObject, 200);
            else writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteBinding(id);
            if (result.success) res.writeBody("", 204);
            else writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeBinding(ref ServiceBinding b)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(b.id);
        j["serviceInstanceId"] = Json(b.serviceInstanceId);
        j["namespaceId"] = Json(b.namespaceId);
        j["environmentId"] = Json(b.environmentId);
        j["tenantId"] = Json(b.tenantId);
        j["name"] = Json(b.name);
        j["description"] = Json(b.description);
        j["status"] = Json(b.status.to!string);
        j["secretName"] = Json(b.secretName);
        j["secretNamespace"] = Json(b.secretNamespace);
        j["parameters"] = Json(b.parametersJson);
        j["labels"] = serializeStrMap(b.labels);
        j["createdBy"] = Json(b.createdBy);
        j["createdAt"] = Json(b.createdAt);
        j["modifiedAt"] = Json(b.modifiedAt);
        return j;
    }
}
