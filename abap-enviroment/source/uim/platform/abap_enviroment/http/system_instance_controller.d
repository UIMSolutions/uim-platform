module uim.platform.abap_enviroment.presentation.http.system_instance;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;^

import uim.platform.abap_enviroment.application.use_cases.manage_system_instances;
import uim.platform.abap_enviroment.application.dto;
import domain.entities.system_instance;
import domain.types;
import uim.platform.abap_enviroment.presentation.http.json_utils;

class SystemInstanceController {
    private ManageSystemInstancesUseCase uc;

    this(ManageSystemInstancesUseCase uc) {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router) {
        router.post("/api/v1/systems", &handleCreate);
        router.get("/api/v1/systems", &handleList);
        router.get("/api/v1/systems/*", &handleGetById);
        router.put("/api/v1/systems/*", &handleUpdate);
        router.delete_("/api/v1/systems/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateSystemInstanceRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.subaccountId = j.getString("subaccountId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.plan = j.getString("plan");
            r.region = j.getString("region");
            r.sapSystemId = j.getString("sapSystemId");
            r.adminEmail = j.getString("adminEmail");
            r.abapRuntimeSize = jsonUshort(j, "abapRuntimeSize");
            r.hanaMemorySize = jsonUshort(j, "hanaMemorySize");
            r.softwareVersion = j.getString("softwareVersion");
            r.stackVersion = j.getString("stackVersion");

            auto result = uc.createInstance(r);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto instances = uc.listInstances(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref inst; instances)
                arr ~= serializeInstance(inst);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)instances.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto inst = uc.getInstance(id);
            if (inst is null) {
                writeError(res, 404, "System instance not found");
                return;
            }
            res.writeJsonBody(serializeInstance(*inst), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateSystemInstanceRequest r;
            r.description = j.getString("description");
            r.status = j.getString("status");
            r.abapRuntimeSize = jsonUshort(j, "abapRuntimeSize");
            r.hanaMemorySize = jsonUshort(j, "hanaMemorySize");
            r.softwareVersion = j.getString("softwareVersion");

            auto result = uc.updateInstance(id, r);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteInstance(id);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["status"] = Json("deleting");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeInstance(ref const SystemInstance inst) {
        auto j = Json.emptyObject;
        j["id"] = Json(inst.id);
        j["tenantId"] = Json(inst.tenantId);
        j["subaccountId"] = Json(inst.subaccountId);
        j["name"] = Json(inst.name);
        j["description"] = Json(inst.description);
        j["plan"] = Json(inst.plan.to!string);
        j["status"] = Json(inst.status.to!string);
        j["region"] = Json(inst.region);
        j["sapSystemId"] = Json(inst.sapSystemId);
        j["adminEmail"] = Json(inst.adminEmail);
        j["abapRuntimeSize"] = Json(cast(long)inst.abapRuntimeSize);
        j["hanaMemorySize"] = Json(cast(long)inst.hanaMemorySize);
        j["serviceUrl"] = Json(inst.serviceUrl);
        j["softwareVersion"] = Json(inst.softwareVersion);
        j["stackVersion"] = Json(inst.stackVersion);
        j["createdAt"] = Json(inst.createdAt);
        j["updatedAt"] = Json(inst.updatedAt);
        return j;
    }
}
