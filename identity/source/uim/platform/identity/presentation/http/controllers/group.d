/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.group;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class GroupController : ManageController {
    private ManageGroupsUseCase usecase;

    this(ManageGroupsUseCase usecase) { this.usecase = usecase; }

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
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Groups retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = Groupprecheck.id);
            auto e = usecase.getGroup(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Group not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            GroupDTO dto;
            dto.groupId = GroupId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.type_ = j.getString("type");

            auto result = usecase.createGroup(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Group created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            GroupDTO dto;
            dto.groupId = Groupprecheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");

            auto result = usecase.updateGroup(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Group updated successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = Groupprecheck.id);
            auto result = usecase.deleteGroup(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Group deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
