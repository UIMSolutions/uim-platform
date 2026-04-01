module presentation.http.business_user;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import application.use_cases.manage_business_users;
// import application.dto;
// import domain.entities.business_user;
// import domain.types;
// import presentation.http.json_utils;

import presentation.http;

Mixin(ShowModule!());

@safe:
class BusinessUserController {
    private ManageBusinessUsersUseCase uc;

    this(ManageBusinessUsersUseCase uc) {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router) {
        router.post("/api/v1/business-users", &handleCreate);
        router.get("/api/v1/business-users", &handleList);
        router.get("/api/v1/business-users/*", &handleGetById);
        router.put("/api/v1/business-users/*", &handleUpdate);
        router.delete_("/api/v1/business-users/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateBusinessUserRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.systemInstanceId = j.getString("systemInstanceId");
            r.username = j.getString("username");
            r.firstName = j.getString("firstName");
            r.lastName = j.getString("lastName");
            r.email = j.getString("email");
            r.roleIds = jsonStrArray(j, "roleIds");

            auto result = uc.createUser(r);
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
            auto systemId = req.headers.get("X-System-Id", "");
            auto users = uc.listUsers(systemId);
            auto arr = Json.emptyArray;
            foreach (ref u; users)
                arr ~= serializeUser(u);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)users.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto user = uc.getUser(id);
            if (user is null) {
                writeError(res, 404, "Business user not found");
                return;
            }
            res.writeJsonBody(serializeUser(*user), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateBusinessUserRequest r;
            r.firstName = j.getString("firstName");
            r.lastName = j.getString("lastName");
            r.email = j.getString("email");
            r.status = j.getString("status");
            r.roleIds = jsonStrArray(j, "roleIds");

            auto result = uc.updateUser(id, r);
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
            auto result = uc.deleteUser(id);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["status"] = Json("deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeUser(ref const BusinessUser u) {
        auto j = Json.emptyObject;
        j["id"] = Json(u.id);
        j["tenantId"] = Json(u.tenantId);
        j["systemInstanceId"] = Json(u.systemInstanceId);
        j["username"] = Json(u.username);
        j["firstName"] = Json(u.firstName);
        j["lastName"] = Json(u.lastName);
        j["email"] = Json(u.email);
        j["status"] = Json(u.status.to!string);
        j["passwordChangeRequired"] = Json(u.passwordChangeRequired);
        j["lastLoginAt"] = Json(u.lastLoginAt);
        j["createdAt"] = Json(u.createdAt);
        j["updatedAt"] = Json(u.updatedAt);

        if (u.roleAssignments.length > 0) {
            auto roles = Json.emptyArray;
            foreach (ref ra; u.roleAssignments) {
                auto rj = Json.emptyObject;
                rj["roleId"] = Json(ra.roleId);
                rj["roleName"] = Json(ra.roleName);
                rj["assignedAt"] = Json(ra.assignedAt);
                roles ~= rj;
            }
            j["roleAssignments"] = roles;
        }

        return j;
    }
}
