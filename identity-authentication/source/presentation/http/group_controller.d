module presentation.http.group_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.use_cases.manage_groups;
import application.dto;
import domain.entities.group;
import presentation.http.json_utils;

/// HTTP controller for group management API.
class GroupController
{
    private ManageGroupsUseCase useCase;

    this(ManageGroupsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/groups", &handleCreate);
        router.get("/api/v1/groups", &handleList);
        router.get("/api/v1/groups/*", &handleGet);
        router.post("/api/v1/groups/members", &handleAddMember);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateGroupRequest(
                jsonStr(j, "tenantId"),
                jsonStr(j, "name"),
                jsonStr(j, "description")
            );

            auto result = useCase.createGroup(createReq);
            auto response = Json.emptyObject;

            if (result.isSuccess())
            {
                response["groupId"] = Json(result.groupId);
                res.writeJsonBody(response, 201);
            }
            else
            {
                response["error"] = Json(result.error);
                res.writeJsonBody(response, 400);
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto groups = useCase.listGroups(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) groups.length);
            response["resources"] = toJsonArray(groups);
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
            import std.string : lastIndexOf;
            auto path = req.requestURI;
            auto idx = path.lastIndexOf('/');
            auto groupId = idx >= 0 ? path[idx + 1 .. $] : "";

            auto group = useCase.getGroup(groupId);
            if (group == Group.init)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json("Group not found");
                res.writeJsonBody(errRes, 404);
                return;
            }

            res.writeJsonBody(toJsonValue(group), 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto error = useCase.addMember(
                jsonStr(j, "groupId"),
                jsonStr(j, "userId")
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
                resp["status"] = Json("member_added");
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
