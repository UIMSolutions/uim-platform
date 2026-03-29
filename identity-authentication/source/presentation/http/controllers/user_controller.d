module presentation.http.user_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.identity_authentication.application.use_cases.manage_users;
import uim.platform.identity_authentication.application.dto;
import uim.platform.identity_authentication.domain.entities.user;
import presentation.http.json_utils;

/// HTTP controller for SCIM-like user management API.
class UserController
{
    private ManageUsersUseCase useCase;

    this(ManageUsersUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/users", &handleCreate);
        router.get("/api/v1/users", &handleList);
        router.get("/api/v1/users/*", &handleGet);
        router.put("/api/v1/users/*", &handleUpdate);
        router.post("/api/v1/users/change-password", &handleChangePassword);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateUserRequest(
                jsonStr(j, "tenantId"),
                jsonStr(j, "userName"),
                jsonStr(j, "email"),
                jsonStr(j, "firstName"),
                jsonStr(j, "lastName"),
                jsonStr(j, "password"),
                jsonStr(j, "phoneNumber")
            );

            auto result = useCase.createUser(createReq);
            auto response = Json.emptyObject;

            if (result.isSuccess())
            {
                response["userId"] = Json(result.userId);
                res.writeJsonBody(response, 201);
            }
            else
            {
                response["error"] = Json(result.error);
                res.writeJsonBody(response, 409);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.params.get("tenantId", "");
            if (tenantId.length == 0)
                tenantId = req.headers.get("X-Tenant-Id", "");

            auto users = useCase.listUsers(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) users.length);
            response["resources"] = toJsonArray(users);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            import std.conv : to;
            auto path = req.requestURI;
            auto userId = extractIdFromPath(path);

            auto user = useCase.getUser(userId);
            if (user == User.init)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json("User not found");
                res.writeJsonBody(errRes, 404);
                return;
            }

            auto response = toJsonValue(user);
            // Remove sensitive field
            response.remove("passwordHash");
            response.remove("mfaSecret");
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto path = req.requestURI;
            auto userId = extractIdFromPath(path);
            auto j = req.json;

            auto updateReq = UpdateUserRequest(
                userId,
                jsonStr(j, "firstName"),
                jsonStr(j, "lastName"),
                jsonStr(j, "phoneNumber")
            );

            auto error = useCase.updateUser(updateReq);
            if (error.length > 0)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json(error);
                res.writeJsonBody(errRes, 404);
            }
            else
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleChangePassword(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto error = useCase.changePassword(
                jsonStr(j, "userId"),
                jsonStr(j, "oldPassword"),
                jsonStr(j, "newPassword")
            );

            if (error.length > 0)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json(error);
                res.writeJsonBody(errRes, 400);
            }
            else
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("password_changed");
                res.writeJsonBody(resp, 200);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }
}

private string extractIdFromPath(string path)
{
    import std.string : lastIndexOf;
    auto idx = path.lastIndexOf('/');
    if (idx >= 0 && idx + 1 < path.length)
        return path[idx + 1 .. $];
    return "";
}
