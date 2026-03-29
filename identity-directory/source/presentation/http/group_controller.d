module presentation.http.group_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.use_cases.manage_groups;
import application.dto;
import domain.entities.group;
import presentation.http.json_utils;

/// HTTP controller for SCIM 2.0 group management.
class GroupController
{
    private ManageGroupsUseCase useCase;

    this(ManageGroupsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/scim/Groups", &handleCreate);
        router.get("/scim/Groups", &handleList);
        router.get("/scim/Groups/*", &handleGet);
        router.put("/scim/Groups/*", &handleUpdate);
        router.delete_("/scim/Groups/*", &handleDelete);
        router.post("/scim/Groups/members", &handleAddMember);
        router.delete_("/scim/Groups/members", &handleRemoveMember);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto members = parseMembers(j);
            auto createReq = CreateGroupRequest(
                req.headers.get("X-Tenant-Id", ""),
                jsonStr(j, "externalId"),
                jsonStr(j, "displayName"),
                jsonStr(j, "description"),
                members,
            );

            auto result = useCase.createGroup(createReq);
            auto response = Json.emptyObject;

            if (result.isSuccess())
            {
                response["id"] = Json(result.groupId);
                response["schemas"] = Json.emptyArray;
                response["schemas"] ~= Json("urn:ietf:params:scim:schemas:core:2.0:Group");
                res.writeJsonBody(response, 201);
            }
            else
            {
                writeScimError(res, 409, result.error);
            }
        }
        catch (Exception e)
        {
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto groups = useCase.listGroups(tenantId);
            auto response = Json.emptyObject;
            response["schemas"] = Json.emptyArray;
            response["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:ListResponse");
            response["totalResults"] = Json(cast(long) groups.length);
            response["Resources"] = toJsonArray(groups);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto groupId = extractIdFromPath(req.requestURI);
            auto group = useCase.getGroup(groupId);
            if (group == Group.init)
            {
                writeScimError(res, 404, "Group not found");
                return;
            }
            res.writeJsonBody(toJsonValue(group), 200);
        }
        catch (Exception e)
        {
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto groupId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateGroupRequest(
                groupId,
                jsonStr(j, "displayName"),
                jsonStr(j, "description"),
            );
            auto error = useCase.updateGroup(updateReq);
            if (error.length > 0)
            {
                writeScimError(res, 404, error);
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
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto groupId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteGroup(groupId);
            if (error.length > 0)
                writeScimError(res, 404, error);
            else
                res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto addReq = AddMemberRequest(
                jsonStr(j, "groupId"),
                jsonStr(j, "memberId"),
                jsonStr(j, "memberType"),
                jsonStr(j, "display"),
            );
            auto error = useCase.addMember(addReq);
            if (error.length > 0)
            {
                writeScimError(res, 400, error);
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
            writeScimError(res, 500, "Internal server error");
        }
    }

    private void handleRemoveMember(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto removeReq = RemoveMemberRequest(
                jsonStr(j, "groupId"),
                jsonStr(j, "memberId"),
            );
            auto error = useCase.removeMember(removeReq);
            if (error.length > 0)
            {
                writeScimError(res, 400, error);
            }
            else
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("member_removed");
                res.writeJsonBody(resp, 200);
            }
        }
        catch (Exception e)
        {
            writeScimError(res, 500, "Internal server error");
        }
    }
}

private GroupMember[] parseMembers(Json j)
{
    import domain.entities.group : GroupMember;
    GroupMember[] result;
    if (j.type != Json.Type.object)
        return result;
    auto val = "members" in j;
    if (val is null || (*val).type != Json.Type.array)
        return result;
    foreach (item; *val)
    {
        result ~= GroupMember(
            jsonStr(item, "value"),
            jsonStr(item, "type"),
            jsonStr(item, "display"),
        );
    }
    return result;
}

private void writeScimError(scope HTTPServerResponse res, int status, string detail)
{
    auto errRes = Json.emptyObject;
    errRes["schemas"] = Json.emptyArray;
    errRes["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
    errRes["detail"] = Json(detail);

    import std.conv : to;
    errRes["status"] = Json(status.to!string);
    res.writeJsonBody(errRes, status);
}
