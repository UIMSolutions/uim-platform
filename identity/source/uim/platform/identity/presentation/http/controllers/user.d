/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.user;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class UserController : ManageController {
    private ManageUsersUseCase usecase;

    this(ManageUsersUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ias/users", &handleList);
        router.get("/api/v1/ias/users/*", &handleGet);
        router.post("/api/v1/ias/users", &handleCreate);
        router.put("/api/v1/ias/users/*", &handleUpdate);
        router.delete_("/api/v1/ias/users/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listUsers(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Users retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = Userprecheck.id);
            auto e = usecase.getUser(tenantId, id);
            if (e.isNull) { writeError(res, 404, "User not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            UserDTO dto;
            dto.userId = UserId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.userName = j.getString("userName");
            dto.email = j.getString("email");
            dto.displayName = j.getString("displayName");
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.phoneNumber = j.getString("phoneNumber");
            dto.language = j.getString("language");
            dto.locale = j.getString("locale");
            dto.timeZone = j.getString("timeZone");
            dto.type_ = j.getString("type");
            dto.password = j.getString("password");

            auto result = usecase.createUser(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "User created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            UserDTO dto;
            dto.userId = Userprecheck.id);
            dto.tenantId = tenantId;
            dto.displayName = j.getString("displayName");
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.phoneNumber = j.getString("phoneNumber");
            dto.language = j.getString("language");
            dto.locale = j.getString("locale");
            dto.timeZone = j.getString("timeZone");
            dto.status = j.getString("status");

            auto result = usecase.updateUser(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "User updated successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = Userprecheck.id);
            auto result = usecase.deleteUser(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "User deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
