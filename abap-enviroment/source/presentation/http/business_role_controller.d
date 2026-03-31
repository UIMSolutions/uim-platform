module presentation.http.business_role;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_business_roles;
import application.dto;
import domain.entities.business_role;
import domain.types;
import presentation.http.json_utils;

class BusinessRoleController
{
    private ManageBusinessRolesUseCase uc;

    this(ManageBusinessRolesUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/business-roles", &handleCreate);
        router.get("/api/v1/business-roles", &handleList);
        router.get("/api/v1/business-roles/*", &handleGetById);
        router.put("/api/v1/business-roles/*", &handleUpdate);
        router.delete_("/api/v1/business-roles/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateBusinessRoleRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.systemInstanceId = jsonStr(j, "systemInstanceId");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.roleType = jsonStr(j, "roleType");
            r.restrictionTypes = jsonStrArray(j, "restrictionTypes");

            auto result = uc.createRole(r);
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
            auto roles = uc.listRoles(systemId);
            auto arr = Json.emptyArray;
            foreach (ref role; roles)
                arr ~= serializeRole(role);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) roles.length);
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
            auto role = uc.getRole(id);
            if (role is null)
            {
                writeError(res, 404, "Business role not found");
                return;
            }
            res.writeJsonBody(serializeRole(*role), 200);
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
            UpdateBusinessRoleRequest r;
            r.description = jsonStr(j, "description");
            r.roleType = jsonStr(j, "roleType");
            r.restrictionTypes = jsonStrArray(j, "restrictionTypes");

            auto result = uc.updateRole(id, r);
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
            auto result = uc.deleteRole(id);
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

    private static Json serializeRole(ref const BusinessRole role)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(role.id);
        j["tenantId"] = Json(role.tenantId);
        j["systemInstanceId"] = Json(role.systemInstanceId);
        j["name"] = Json(role.name);
        j["description"] = Json(role.description);
        j["roleType"] = Json(role.roleType.to!string);
        j["createdAt"] = Json(role.createdAt);
        j["updatedAt"] = Json(role.updatedAt);

        if (role.restrictionTypes.length > 0)
        {
            auto rt = Json.emptyArray;
            foreach (ref r; role.restrictionTypes)
                rt ~= Json(r);
            j["restrictionTypes"] = rt;
        }

        if (role.assignedCatalogs.length > 0)
        {
            auto cats = Json.emptyArray;
            foreach (ref c; role.assignedCatalogs)
            {
                auto cj = Json.emptyObject;
                cj["catalogId"] = Json(c.catalogId);
                cj["catalogName"] = Json(c.catalogName);
                cats ~= cj;
            }
            j["assignedCatalogs"] = cats;
        }

        return j;
    }
}
