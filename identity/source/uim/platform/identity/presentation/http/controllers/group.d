/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.group;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class GroupController : ManageHttpController {
    private ManageGroupsUseCase usecase;

    this(ManageGroupsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ias/groups", &handleList);
        router.get("/api/v1/ias/groups/*", &handleGet);
        router.post("/api/v1/ias/groups", &handleCreate);
        router.put("/api/v1/ias/groups/*", &handleUpdate);
        router.delete_("/api/v1/ias/groups/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listGroups(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;
        res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Groups retrieved successfully"), 200);
    }
 catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GroupId(precheck.id);
    auto e = usecase.getGroup(tenantId, id);
    if (e.isNull) {
        writeError(res, 404, "Group not found");
        return;
    }
    res.writeJsonBody(e.toJson(), 200);
}
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    GroupDTO dto;
    dto.groupId = GroupId(precheck.id);
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.type_ = data.getString("type");

    auto result = usecase.createGroup(dto);
if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Group created successfully", "Created", 201, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    GroupDTO dto;
    dto.groupId = GroupId(precheck.id);
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");

    auto result = usecase.updateGroup(dto);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Group updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GroupId(precheck.id);
    auto result = usecase.deleteGroup(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Group deleted successfully", "Deleted", 200, responseData);
}

}
