module uim.platform.identity_authentication.presentation.http.config_change_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

import application.use_cases.write_config_change;
import application.dto;
import domain.types;
import domain.entities.audit_log_entry : AuditAttribute;
import uim.platform.identity_authentication.presentation.http.json_utils;

class ConfigChangeController
{
    private WriteConfigChangeUseCase useCase;

    this(WriteConfigChangeUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/config-changes", &handleWrite);
    }

    private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = WriteConfigChangeLogRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.changedBy = jsonStr(j, "changedBy");
            r.configType = jsonStr(j, "configType");
            r.configObjectId = jsonStr(j, "configObjectId");
            r.reason = jsonStr(j, "reason");
            r.changes = parseChanges(j);

            auto result = useCase.writeChange(r);
            if (result.isSuccess())
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

    private static AuditAttribute[] parseChanges(Json j)
    {
        AuditAttribute[] result;
        auto v = "changes" in j;
        if (v is null || (*v).type != Json.Type.array)
            return result;
        foreach (item; *v)
        {
            if (item.type == Json.Type.object)
            {
                result ~= AuditAttribute(
                    jsonStr(item, "name"),
                    jsonStr(item, "oldValue"),
                    jsonStr(item, "newValue")
                );
            }
        }
        return result;
    }
}
