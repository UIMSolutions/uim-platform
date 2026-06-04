/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.queue;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// HTTP controller for qRFC/bgRFC queue management.
/// Endpoints:
///   GET    /api/v1/rfc/queues/*          — list entries in a named queue
///   POST   /api/v1/rfc/queues/*/process  — process all pending entries in a queue
///   DELETE /api/v1/rfc/queues/entries/*  — delete a specific queue entry
class QueueController : HttpController {

    private ManageQueuesUseCase _usecase;

    this(ManageQueuesUseCase usecase) { _usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get    ("/api/v1/rfc/queues/*",           &handleList);
        router.post   ("/api/v1/rfc/queues/*/process",   &handleProcess);
        router.delete_("/api/v1/rfc/queues/entries/*",   &handleDeleteEntry);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            auto queueName = extractIdFromPath(req.requestURI.to!string);
            auto entries   = _usecase.listQueue(tenantId, queueName);
            auto jarr      = Json.emptyArray;
            foreach (e; entries) jarr ~= e.toJson();
            res.writeJsonBody(Json.emptyObject
                .set("queue",   queueName)
                .set("count",   cast(long) entries.length)
                .set("items",   jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleProcess(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            // Path: /api/v1/rfc/queues/<queueName>/process — extract queue name
            auto path      = req.requestURI.to!string;
            auto parts     = path.split("/");
            // parts: ["", "api", "v1", "rfc", "queues", "<queueName>", "process"]
            auto queueName = parts.length >= 6 ? parts[5] : "";

            ProcessQueueRequest r;
            r.tenantId  = tenantId;
            r.queueName = queueName;

            auto result = _usecase.processQueue(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject
                    .set("processed", cast(long) result.processed)
                    .set("message",   "Queue processed"), 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDeleteEntry(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = _usecase.deleteQueueEntry(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("message", "Queue entry deleted"), 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
