module uim.platform.auditlog.presentation.http.controllers.data_access;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

import uim.platform.auditlog.application.usecases.write.data_access_log;
import uim.platform.auditlog.application.dto;
import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.presentation.http.json_utils;

@safe: class DataAccessController
{
    private WriteDataAccessLogUseCase useCase;

    this(WriteDataAccessLogUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/data-access", &handleWrite);
    }

    private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = WriteDataAccessLogRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.accessedBy = jsonStr(j, "accessedBy");
            r.dataSubject = jsonStr(j, "dataSubject");
            r.dataObjectType = jsonStr(j, "dataObjectType");
            r.dataObjectId = jsonStr(j, "dataObjectId");
            r.accessedFields = jsonStrArray(j, "accessedFields");
            r.purpose = jsonStr(j, "purpose");
            r.channel = jsonStr(j, "channel");

            auto result = useCase.writeLog(r);
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
}
