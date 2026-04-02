module uim.platform.management.presentation.http.controllers.environment;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

import application.usecases.manage_environment_instances;
import application.dto;
import uim.platform.management.domain.entities.environment_instance;
import uim.platform.management.domain.types;
import presentation.http.json_utils;

class EnvironmentController
{
    private ManageEnvironmentInstancesUseCase uc;

    this(ManageEnvironmentInstancesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/environments", &handleCreate);
        router.get("/api/v1/environments", &handleList);
        router.get("/api/v1/environments/*", &handleGet);
        router.put("/api/v1/environments/*", &handleUpdate);
        router.post("/api/v1/environments/deprovision/*", &handleDeprovision);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateEnvironmentInstanceRequest r;
            r.subaccountId = j.getString("subaccountId");
            r.globalAccountId = j.getString("globalAccountId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.environmentType = j.getString("environmentType");
            r.planName = j.getString("planName");
            r.landscapeLabel = j.getString("landscapeLabel");
            r.memoryQuotaMb = j.getInteger("memoryQuotaMb");
            r.routeQuota = j.getInteger("routeQuota");
            r.serviceQuota = j.getInteger("serviceQuota");
            r.createdBy = req.headers.get("X-User-Id", "");
            r.parameters = jsonStrMap(j, "parameters");
            r.labels = jsonStrMap(j, "labels");

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
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto subId = req.params.get("subaccountId");
            auto envType = req.params.get("environmentType");

            EnvironmentInstance[] items;
            if (envType.length > 0 && subId.length > 0)
                items = uc.listByType(subId, envType);
            else if (subId.length > 0)
                items = uc.listBySubaccount(subId);

            auto arr = Json.emptyArray;
            foreach (ref inst; items)
                arr ~= serializeEnvironment(inst);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractId(req.requestURI);
            auto inst = uc.getById(id);
            if (inst.id.length == 0)
            {
                writeError(res, 404, "Environment instance not found");
                return;
            }
            res.writeJsonBody(serializeEnvironment(inst), 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractId(req.requestURI);
            auto j = req.json;
            UpdateEnvironmentInstanceRequest r;
            r.description = j.getString("description");
            r.memoryQuotaMb = j.getInteger("memoryQuotaMb");
            r.routeQuota = j.getInteger("routeQuota");
            r.serviceQuota = j.getInteger("serviceQuota");
            r.parameters = jsonStrMap(j, "parameters");
            r.labels = jsonStrMap(j, "labels");

            auto result = uc.update(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDeprovision(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractId(req.requestURI);
            auto result = uc.deprovision(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }
}

private Json serializeEnvironment(ref EnvironmentInstance inst)
{
    auto j = Json.emptyObject;
    j["id"] = Json(inst.id);
    j["subaccountId"] = Json(inst.subaccountId);
    j["globalAccountId"] = Json(inst.globalAccountId);
    j["name"] = Json(inst.name);
    j["description"] = Json(inst.description);
    j["environmentType"] = Json(enumStr(inst.environmentType));
    j["status"] = Json(enumStr(inst.status));
    j["planName"] = Json(inst.planName);
    j["landscapeLabel"] = Json(inst.landscapeLabel);
    j["technicalKey"] = Json(inst.technicalKey);
    j["dashboardUrl"] = Json(inst.dashboardUrl);
    j["memoryQuotaMb"] = Json(cast(long) inst.memoryQuotaMb);
    j["routeQuota"] = Json(cast(long) inst.routeQuota);
    j["serviceQuota"] = Json(cast(long) inst.serviceQuota);
    j["createdBy"] = Json(inst.createdBy);
    j["createdAt"] = Json(inst.createdAt);
    j["modifiedAt"] = Json(inst.modifiedAt);
    j["parameters"] = serializeStrMap(inst.parameters);
    j["labels"] = serializeStrMap(inst.labels);
    return j;
}

private string enumStr(E)(E val) { import std.conv : to; return val.to!string; }
