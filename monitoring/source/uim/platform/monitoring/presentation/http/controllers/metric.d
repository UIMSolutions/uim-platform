module presentation.http.metric;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.manage_metrics;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.metric;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.presentation.http.json_utils;

class MetricController
{
    private ManageMetricsUseCase uc;

    this(ManageMetricsUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/metrics", &handlePush);
        router.post("/api/v1/metrics/batch", &handleBatchPush);
        router.get("/api/v1/metrics", &handleQuery);
        router.get("/api/v1/metrics/summary", &handleSummary);
    }

    private void handlePush(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            PushMetricRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.resourceId = j.getString("resourceId");
            r.name = j.getString("name");
            r.value_ = jsonDouble(j, "value");
            r.unit = j.getString("unit");
            r.category = j.getString("category");

            auto result = uc.pushMetric(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleBatchPush(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto tenantId = req.headers.get("X-Tenant-Id", "");

            PushMetricBatchRequest batchReq;
            batchReq.tenantId = tenantId;

            auto metricsVal = "metrics" in j;
            if (metricsVal !is null && (*metricsVal).type == Json.Type.array)
            {
                foreach (mj; *metricsVal)
                {
                    if (m!j.isObject)
                        continue;
                    PushMetricRequest r;
                    r.tenantId = tenantId;
                    r.resourceId = mj.getString( "resourceId");
                    r.name = mj.getString( "name");
                    r.value_ = jsonDouble(mj, "value");
                    r.unit = mj.getString( "unit");
                    r.category = mj.getString( "category");
                    batchReq.metrics ~= r;
                }
            }

            auto result = uc.pushMetricBatch(batchReq);
            auto resp = Json.emptyObject;
            resp["accepted"] = Json(cast(long) batchReq.metrics.length);
            res.writeJsonBody(resp, 201);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto resourceId = req.params.get("resourceId", "");
            auto metricName = req.params.get("name", "");

            QueryMetricsRequest qr;
            qr.tenantId = tenantId;
            qr.resourceId = resourceId;
            qr.metricName = metricName;

            auto metrics = uc.queryMetrics(qr);

            auto arr = Json.emptyArray;
            foreach (ref m; metrics)
                arr ~= serializeMetric(m);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) metrics.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto resourceId = req.params.get("resourceId", "");
            auto metricName = req.params.get("name", "");

            import std.datetime.systime : Clock;
            auto now = Clock.currTime().toUnixTime();
            auto windowStart = now - 3600; // Default 1 hour window

            auto summary = uc.computeSummary(tenantId, resourceId, metricName, windowStart, now);

            auto resp = Json.emptyObject;
            resp["name"] = Json(summary.name);
            resp["resourceId"] = Json(summary.resourceId);
            resp["minValue"] = Json(summary.minValue);
            resp["maxValue"] = Json(summary.maxValue);
            resp["avgValue"] = Json(summary.avgValue);
            resp["sumValue"] = Json(summary.sumValue);
            resp["dataPointCount"] = Json(summary.dataPointCount);
            resp["windowStartTime"] = Json(summary.windowStartTime);
            resp["windowEndTime"] = Json(summary.windowEndTime);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeMetric(const ref Metric m)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(m.id);
        j["tenantId"] = Json(m.tenantId);
        j["resourceId"] = Json(m.resourceId);
        j["definitionId"] = Json(m.definitionId);
        j["name"] = Json(m.name);
        j["value"] = Json(m.value_);
        j["unit"] = Json(m.unit.to!string);
        j["category"] = Json(m.category.to!string);
        j["timestamp"] = Json(m.timestamp);
        return j;
    }
}
