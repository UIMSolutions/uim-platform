/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.xyz.presentation.http.controllers.change_log;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.query_change_log;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.change_log_entry;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.presentation.http.json_utils;

class ChangeLogController
{
    private QueryChangeLogUseCase uc;

    this(QueryChangeLogUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.get("/api/v1/change-log", &handleQuery);
        router.get("/api/v1/change-log/*", &handleGetById);
    }

    private void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            ChangeLogQueryRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.objectId = req.params.get("objectId", "");
            r.category = req.params.get("category", "");
            r.deltaToken = req.params.get("deltaToken", "");

            auto sinceStr = req.params.get("since", "");
            if (sinceStr.length > 0)
            {
                import std.conv : to;
                try r.sinceTimestamp = sinceStr.to!long;
                catch (Exception) {}
            }

            auto entries = uc.query(r);

            auto arr = Json.emptyArray;
            foreach (ref e; entries)
                arr ~= serializeEntry(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) entries.length);

            // Provide the last delta token for incremental polling
            if (entries.length > 0)
                resp["nextDeltaToken"] = Json(entries[$ - 1].deltaToken);

            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto entry = uc.getEntry(id);
            if (entry.id.length == 0)
            {
                writeError(res, 404, "Change log entry not found");
                return;
            }
            res.writeJsonBody(serializeEntry(entry), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeEntry(ref ChangeLogEntry e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["objectId"] = Json(e.objectId);
        j["dataModelId"] = Json(e.dataModelId);
        j["category"] = Json(e.category.to!string);
        j["changeType"] = Json(e.changeType.to!string);
        j["objectType"] = Json(e.objectType);
        j["changedFields"] = serializeStrArray(e.changedFields);
        j["oldValues"] = serializeStrMap(e.oldValues);
        j["newValues"] = serializeStrMap(e.newValues);
        j["sourceSystem"] = Json(e.sourceSystem);
        j["sourceClient"] = Json(e.sourceClient);
        j["changedBy"] = Json(e.changedBy);
        j["fromVersion"] = Json(e.fromVersion);
        j["toVersion"] = Json(e.toVersion);
        j["deltaToken"] = Json(e.deltaToken);
        j["timestamp"] = Json(e.timestamp);
        return j;
    }
}
