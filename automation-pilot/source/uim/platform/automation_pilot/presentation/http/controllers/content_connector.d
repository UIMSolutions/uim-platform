/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.content_connector;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ContentConnectorController : ManageController {
    private ManageContentConnectorsUseCase usecase;

    this(ManageContentConnectorsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/automation-pilot/content-connectors", &handleList);
        router.get("/api/v1/automation-pilot/content-connectors/*", &handleGet);
        router.post("/api/v1/automation-pilot/content-connectors", &handleCreate);
        router.put("/api/v1/automation-pilot/content-connectors/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/content-connectors/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            
            auto items = usecase.listContentConnectors(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ContentConnectorId(precheck.id);

            auto e = usecase.getContentConnector(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Content connector not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;
            ContentConnectorDTO dto;
            dto.contentConnectorId = ContentConnectorId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.repositoryUrl = data.getString("repositoryUrl");
            dto.branch = data.getString("branch");
            dto.path = data.getString("path");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createContentConnector(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Content connector created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ContentConnectorDTO dto;
            dto.contentConnectorId = ContentConnectorId(precheck.id);
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.repositoryUrl = data.getString("repositoryUrl");
            dto.branch = data.getString("branch");
            dto.path = data.getString("path");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateContentConnector(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Content connector updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto contentConnectorId = ContentConnectorId(precheck.id);

            auto result = usecase.deleteContentConnector(tenantId, contentConnectorId);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Content connector deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
