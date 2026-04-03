module uim.platform.portal.presentation.http.controllers.role;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.xyz.application.usecases.manage_roles;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.role;
import uim.platform.xyz.domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class RoleController
{
    private ManageRolesUseCase useCase;

    this(ManageRolesUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/roles", &handleCreate);
        router.get("/api/v1/roles", &handleList);
        router.get("/api/v1/roles/*", &handleGet);
        router.put("/api/v1/roles/*", &handleUpdate);
        router.delete_("/api/v1/roles/*", &handleDelete);
        router.post("/api/v1/roles/assign", &handleAssign);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateRoleRequest(
                req.headers.get("X-Tenant-Id", ""),
                j.getString("name"),
                j.getString("description"),
                jsonEnum!RoleScope(j, "scope", RoleScope.site),
            );

            auto result = useCase.createRole(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.roleId);
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
            auto roles = useCase.listRoles(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) roles.length);
            response["resources"] = toJsonArray(roles);
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
            auto roleId = extractIdFromPath(req.requestURI);
            auto role = useCase.getRole(roleId);
            if (role == Role.init)
            {
                writeApiError(res, 404, "Role not found");
                return;
            }
            res.writeJsonBody(toJsonValue(role), 200);
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
            auto roleId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateRoleRequest(
                roleId,
                j.getString("name"),
                j.getString("description"),
            );

            auto error = useCase.updateRole(updateReq);
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

    private void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto assignReq = AssignRoleRequest(
                j.getString("roleId"),
                jsonStrArray(j, "userIds"),
                jsonStrArray(j, "groupIds"),
            );

            auto error = useCase.assignRole(assignReq);
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
            auto roleId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteRole(roleId);
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
