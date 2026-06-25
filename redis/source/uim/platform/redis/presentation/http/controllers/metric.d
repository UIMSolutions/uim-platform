/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.metric;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class MetricController : ManageHttpController {
    private ManageMetricsUseCase metrics;

    this(ManageMetricsUseCase metrics) {
        this.metrics = metrics;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/metrics",   &handleList);
        router.get("/api/v1/redis/metrics/*", &handleGet);
        router.post("/api/v1/redis/metrics",  &handleCreate);
        router.delete_("/api/v1/redis/metrics/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = metrics.listMetrics(tenantId);
        return successResponse("Metrics retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MetricId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid metric ID", 400);

        auto e = metrics.getMetric(tenantId, id);
        if (e.isNull)
            return errorResponse("Metric not found", 404);

        return successResponse("Metric retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        MetricDTO dto;
        dto.metricId                = MetricId(data.getString("metricId", ""));
        dto.tenantId                = tenantId;
        dto.instanceId              = ServiceInstanceId(data.getString("instanceId", ""));
        dto.timestamp_              = data.getLong("timestamp", 0);
        dto.memoryUsedMb            = data.getLong("memoryUsedMb", 0);
        dto.memoryTotalMb           = data.getLong("memoryTotalMb", 0);
        dto.connectedClients        = data.getLong("connectedClients", 0);
        dto.commandsPerSecond       = data.getLong("commandsPerSecond", 0);
        dto.hitRate                 = data.getDouble("hitRate", 0.0);
        dto.evictedKeys             = data.getLong("evictedKeys", 0);
        dto.expiredKeys             = data.getLong("expiredKeys", 0);
        dto.totalCommandsProcessed  = data.getLong("totalCommandsProcessed", 0);
        dto.cpuUsagePercent         = data.getDouble("cpuUsagePercent", 0.0);
        dto.networkInputKbs         = data.getLong("networkInputKbs", 0);
        dto.networkOutputKbs        = data.getLong("networkOutputKbs", 0);
        dto.createdBy               = UserId(data.getString("createdBy", ""));

        auto result = metrics.recordMetric(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Metric recorded successfully", "Created", 201, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MetricId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid metric ID", 400);

        auto result = metrics.deleteMetric(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Metric deleted successfully", "Deleted", 200, Json.emptyObject
            .set("id", result.id));
    }
}
