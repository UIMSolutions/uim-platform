module presentation.http.retention_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_retention;
import application.dto;
import domain.types;
import domain.entities.retention_policy;
import presentation.http.json_utils;

class RetentionController
{
    private ManageRetentionUseCase useCase;

    this(ManageRetentionUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/retention", &handleCreate);
        router.get("/api/v1/retention", &handleList);
        router.get("/api/v1/retention/*", &handleGet);
        router.put("/api/v1/retention/*", &handleUpdate);
        router.delete_("/api/v1/retention/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateRetentionPolicyRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.retentionDays = jsonInt(j, "retentionDays");
            r.isDefault = jsonBool(j, "isDefault");
            r.categories = parseCategoryArray(j);

            auto result = useCase.createPolicy(r);
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto policies = useCase.listPolicies(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref p; policies)
                arr ~= serializePolicy(p);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) policies.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto policy = useCase.getPolicy(id, tenantId);
            if (policy is null)
            {
                writeError(res, 404, "Retention policy not found");
                return;
            }
            res.writeJsonBody(serializePolicy(*policy), 200);
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
            auto j = req.json;
            auto r = UpdateRetentionPolicyRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.retentionDays = jsonInt(j, "retentionDays");
            r.categories = parseCategoryArray(j);

            auto statusStr = jsonStr(j, "status");
            if (statusStr == "inactive") r.status = RetentionStatus.inactive;
            else if (statusStr == "expired") r.status = RetentionStatus.expired;
            else r.status = RetentionStatus.active;

            auto result = useCase.updatePolicy(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deletePolicy(id, tenantId);
            auto resp = Json.emptyObject;
            resp["status"] = Json("deleted");
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializePolicy(ref const RetentionPolicy p)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(p.id);
        j["tenantId"] = Json(p.tenantId);
        j["name"] = Json(p.name);
        j["description"] = Json(p.description);
        j["retentionDays"] = Json(cast(long) p.retentionDays);
        j["status"] = Json(p.status.to!string);
        j["isDefault"] = Json(p.isDefault);
        j["createdAt"] = Json(p.createdAt);
        j["updatedAt"] = Json(p.updatedAt);

        if (p.categories.length > 0)
        {
            auto cats = Json.emptyArray;
            foreach (ref c; p.categories)
                cats ~= Json(categoryToString(c));
            j["categories"] = cats;
        }
        return j;
    }

    private static AuditCategory[] parseCategoryArray(Json j)
    {
        AuditCategory[] result;
        auto cats = jsonStrArray(j, "categories");
        foreach (c; cats)
            result ~= parseCategory(c);
        return result;
    }

    private static AuditCategory parseCategory(string s)
    {
        switch (s)
        {
            case "audit.security-events", "securityEvents": return AuditCategory.securityEvents;
            case "audit.configuration", "configuration":    return AuditCategory.configuration;
            case "audit.data-access", "dataAccess":         return AuditCategory.dataAccess;
            case "audit.data-modification", "dataModification": return AuditCategory.dataModification;
            default: return AuditCategory.securityEvents;
        }
    }

    private static string categoryToString(AuditCategory c)
    {
        final switch (c)
        {
            case AuditCategory.securityEvents:    return "audit.security-events";
            case AuditCategory.configuration:     return "audit.configuration";
            case AuditCategory.dataAccess:        return "audit.data-access";
            case AuditCategory.dataModification:  return "audit.data-modification";
        }
    }
}
