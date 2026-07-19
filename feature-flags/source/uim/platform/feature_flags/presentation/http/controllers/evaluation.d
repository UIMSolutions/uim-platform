/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.http.controllers.evaluation;

import uim.platform.feature_flags;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPStatus;
import vibe.data.json   : Json;
import std.conv         : to;
import std.algorithm    : map;
import std.array        : array;

mixin(ShowModule!());

@safe:

/// Provides the runtime evaluation API consumed by application SDKs.
/// Mirrors the SAP Feature Flags service /api/v1/evaluate endpoint.
class EvaluationController {
    private EvaluateFlagsUseCase useCase;

    this(EvaluateFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router) {
        // Single flag evaluation
        router.get("/api/v1/feature-flags/evaluate/*", &handleEvaluate);
        // Bulk evaluation for all flags in an instance
        router.get("/api/v1/feature-flags/evaluate",   &handleEvaluateAll);
    }

    // GET /api/v1/feature-flags/evaluate/:flagName?instanceId=...&tenantId=...&userId=...
    private void handleEvaluate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto path     = req.requestPath.to!string;
        auto flagName = precheck.id;
        if (flagname.isEmpty) { writeError(res, 400, "Flag name required"); return; }

        EvaluationRequest dto;
        dto.flagName   = flagName;
        dto.instanceId = req.query.get("instanceId", "");
        dto.tenantId   = req.query.get("tenantId",   "default");
        dto.userId     = req.query.get("userId",     "");

        // additional attributes from query string (prefix "attr_")
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key.length > 5 && kv.key[0..5] == "attr_")
                dto.attributes[kv.key[5..$]] = kv.value;
        }

        auto result = useCase.evaluate(dto);
        res.writeJsonBody(toJson(result), cast(int) HTTPStatus.ok);
    }

    // GET /api/v1/feature-flags/evaluate?instanceId=...&tenantId=...&userId=...
    private void handleEvaluateAll(HTTPServerRequest req, HTTPServerResponse res) @safe {
        BulkEvaluationRequest dto;
        dto.instanceId = req.query.get("instanceId", "");
        dto.tenantId   = req.query.get("tenantId",   "default");
        dto.userId     = req.query.get("userId",     "");

        foreach (kv; req.query.byKeyValue()) {
            if (kv.key.length > 5 && kv.key[0..5] == "attr_")
                dto.attributes[kv.key[5..$]] = kv.value;
        }

        auto results = useCase.evaluateAll(dto);

        auto jarr = Json.emptyArray;
        foreach (r; results) jarr ~= toJson(r);

        auto j = Json.emptyObject;
        j["count"]     = cast(long) results.length;
        j["evaluations"] = jarr;
        res.writeJsonBody(j, cast(int) HTTPStatus.ok);
    }
}
