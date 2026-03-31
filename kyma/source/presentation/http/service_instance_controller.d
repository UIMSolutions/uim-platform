module presentation.http.service_instance_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_service_instances;
import application.dto;
import domain.entities.service_instance;
import domain.types;
import presentation.http.json_utils;

class ServiceInstanceController
{
    private ManageServiceInstancesUseCase uc;

    this(ManageServiceInstancesUseCase uc) { this.uc = uc; }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/service-instances", &handleCreate);
        router.get("/api/v1/service-instances", &handleList);
        router.get("/api/v1/service-instances/*", &handleGetById);
        router.put("/api/v1/service-instances/*", &handleUpdate);
        router.delete_("/api/v1/service-instances/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateServiceInstanceRequest r;
            r.namespaceId = jsonStr(j, "namespaceId");
            r.environmentId = jsonStr(j, "environmentId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.serviceOfferingName = jsonStr(j, "serviceOfferingName");
            r.servicePlanName = jsonStr(j, "servicePlanName");
            r.servicePlanId = jsonStr(j, "servicePlanId");
            r.externalName = jsonStr(j, "externalName");
            r.parametersJson = jsonStr(j, "parameters");
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
            auto envId = req.params.get("environmentId");

            ServiceInstance[] items;
            if (nsId.length > 0)
                items = uc.listByNamespace(nsId);
            else if (envId.length > 0)
                items = uc.listByEnvironment(envId);
            else
                items = [];

            auto arr = Json.emptyArray;
            foreach (ref inst; items)
                arr ~= serializeInst(inst);

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
            auto inst = uc.getServiceInstance(id);
            if (inst.id.length == 0) { writeError(res, 404, "Service instance not found"); return; }
            res.writeJsonBody(serializeInst(inst), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateServiceInstanceRequest r;
            r.description = jsonStr(j, "description");
            r.servicePlanName = jsonStr(j, "servicePlanName");
            r.servicePlanId = jsonStr(j, "servicePlanId");
            r.parametersJson = jsonStr(j, "parameters");
            r.labels = jsonStrMap(j, "labels");

            auto result = uc.updateServiceInstance(id, r);
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
            auto result = uc.deleteServiceInstance(id);
            if (result.success) res.writeBody("", 204);
            else writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeInst(ref ServiceInstance inst)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(inst.id);
        j["namespaceId"] = Json(inst.namespaceId);
        j["environmentId"] = Json(inst.environmentId);
        j["tenantId"] = Json(inst.tenantId);
        j["name"] = Json(inst.name);
        j["description"] = Json(inst.description);
        j["status"] = Json(inst.status.to!string);
        j["serviceOfferingName"] = Json(inst.serviceOfferingName);
        j["servicePlanName"] = Json(inst.servicePlanName);
        j["servicePlanId"] = Json(inst.servicePlanId);
        j["externalName"] = Json(inst.externalName);
        j["parameters"] = Json(inst.parametersJson);
        j["labels"] = serializeStrMap(inst.labels);
        j["bindingCount"] = Json(cast(long) inst.bindingCount);
        j["createdBy"] = Json(inst.createdBy);
        j["createdAt"] = Json(inst.createdAt);
        j["modifiedAt"] = Json(inst.modifiedAt);
        return j;
    }
}
