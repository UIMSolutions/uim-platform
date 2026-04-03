module uim.platform.data.privacy.presentation.http.deletion;

// import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.data.privacy.application.usecases.manage_deletion_requests;
import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.deletion_request;
import uim.platform.data.privacy.presentation.http.json_utils;

class DeletionController
{
    private ManageDeletionRequestsUseCase uc;

    this(ManageDeletionRequestsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/deletion-requests", &handleCreate);
        router.get("/api/v1/deletion-requests", &handleList);
        router.get("/api/v1/deletion-requests/*", &handleGetById);
        router.put("/api/v1/deletion-requests/*", &handleUpdateStatus);
        router.delete_("/api/v1/deletion-requests/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateDeletionRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.requestedBy = j.getString("requestedBy");
            r.targetSystems = jsonStrArray(j, "targetSystems");
            r.reason = j.getString("reason");

            auto result = uc.createRequest(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto statusParam = req.headers.get("X-Status-Filter", "");
            auto subjectParam = req.headers.get("X-Subject-Filter", "");

            DeletionRequest[] items;
            if (statusParam.length > 0)
                items = uc.listByStatus(tenantId, parseDeletionStatus(statusParam));
            else if (subjectParam.length > 0)
                items = uc.listByDataSubject(tenantId, subjectParam);
            else
                items = uc.listRequests(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref e; items)
                arr ~= serialize(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto entry = uc.getRequest(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Deletion request not found");
                return;
            }
            res.writeJsonBody(serialize(*entry), 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            UpdateDeletionStatusRequest r;
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.status = parseDeletionStatus(j.getString("status"));
            r.blockerReason = j.getString("blockerReason");

            auto result = uc.updateStatus(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            uc.deleteRequest(id, tenantId);
            res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private static Json serialize(ref const DeletionRequest e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["dataSubjectId"] = Json(e.dataSubjectId);
        j["requestedBy"] = Json(e.requestedBy);
        j["requestType"] = Json(e.requestType.to!string);
        j["status"] = Json(e.status.to!string);
        j["reason"] = Json(e.reason);
        j["blockerReason"] = Json(e.blockerReason);
        j["requestedAt"] = Json(e.requestedAt);
        j["completedAt"] = Json(e.completedAt);
        j["deadline"] = Json(e.deadline);

        auto systems = Json.emptyArray;
        foreach (ref s; e.targetSystems)
            systems ~= Json(s);
        j["targetSystems"] = systems;

        auto cats = Json.emptyArray;
        foreach (ref c; e.categories)
            cats ~= Json(c.to!string);
        j["categories"] = cats;

        return j;
    }

    private static DeletionStatus parseDeletionStatus(string s)
    {
        switch (s)
        {
            case "inProgress": return DeletionStatus.inProgress;
            case "completed": return DeletionStatus.completed;
            case "failed": return DeletionStatus.failed;
            case "blocked": return DeletionStatus.blocked;
            default: return DeletionStatus.requested;
        }
    }
}
