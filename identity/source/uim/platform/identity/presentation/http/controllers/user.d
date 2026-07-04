/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.user;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class UserController : ManageHttpController {
    private ManageUsersUseCase usecase;

    this(ManageUsersUseCase usecase) {
        this.usecase = usecase;
    }

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

        auto items = usecase.listUsers(tenantId).map!(e => e.toJson()).array.toJson;
        auto responseDate = Json.emptyObject
            .set("count", items.length)
            .set("resources", items);

        return successResponse("Users retrieved successfully", "Retrieved", 200, responseDate);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = UserId(precheck.id);
        auto e = usecase.getUser(tenantId, id);
        if (e.isNull)
            return errorResponse("User not found", 404);

        return successResponse("User retrieved successfully", "Retrieved", 200, e.toJson);

    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UserDTO dto;
        dto.userId = UserId(precheck.id);
        dto.tenantId = tenantId;
        dto.userName = data.getString("userName");
        dto.email = data.getString("email");
        dto.displayName = data.getString("displayName");
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.phoneNumber = data.getString("phoneNumber");
        dto.language = data.getString("language");
        dto.locale = data.getString("locale");
        dto.timeZone = data.getString("timeZone");
        dto.type_ = data.getString("type");
        dto.password = data.getString("password");

        auto result = usecase.createUser(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("User created successfully", 201, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        UserDTO dto;
        dto.userId = UserId(precheck.id);
        dto.tenantId = tenantId;
        dto.displayName = data.getString("displayName");
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.phoneNumber = data.getString("phoneNumber");
        dto.language = data.getString("language");
        dto.locale = data.getString("locale");
        dto.timeZone = data.getString("timeZone");
        dto.status = data.getString("status");

        auto result = usecase.updateUser(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("User updated successfully", 200, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = UserId(precheck.id);
        auto result = usecase.deleteUser(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("User deleted successfully", 200, Json.emptyObject.set("id", result
                .id));
    }
}
