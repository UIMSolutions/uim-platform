/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.data_connection;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class DataConnectionController : PlatformController {
    private ManageDataConnectionsUseCase usecase;

    this(ManageDataConnectionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/build-apps/data-connections", &handleList);
        router.get("/api/v1/build-apps/data-connections/*", &handleGet);
        router.post("/api/v1/build-apps/data-connections", &handleCreate);
        router.put("/api/v1/build-apps/data-connections/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/data-connections/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = usecase.listDataConnections(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Data connections retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto dataConnectionId = DataConnectionId(extractIdFromPath(path));

            auto e = usecase.getDataConnection(tenantId, dataConnectionId);
            if (e.isNull) { writeError(res, 404, "Data connection not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;
            auto dataConnectionId = DataConnectionId(j.getString("id"));

            DataConnectionDTO dto;
            dto.tenantId = tenantId;
            dto.dataConnectionId = dataConnectionId;
            dto.applicationId = ApplicationId(j.getString("applicationId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.connectionType = j.getString("connectionType");
            dto.authMethod = j.getString("authMethod");
            dto.baseUrl = j.getString("baseUrl");
            dto.basePath = j.getString("basePath");
            dto.headers = j.getString("headers");
            dto.queryParams = j.getString("queryParams");
            dto.responseMapping = j.getString("responseMapping");
            dto.destinationName = j.getString("destinationName");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDataConnection(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data connection created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DataConnectionDTO dto;
            dto.dataConnectionId = DataConnectionId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.baseUrl = j.getString("baseUrl");
            dto.basePath = j.getString("basePath");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDataConnection(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data connection updated");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto dataConnectionId = DataConnectionId(extractIdFromPath(path));

            auto result = usecase.deleteDataConnection(tenantId, dataConnectionId);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Data connection deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
