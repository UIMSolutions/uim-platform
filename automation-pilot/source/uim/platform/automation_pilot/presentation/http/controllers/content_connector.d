/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.content_connector;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ContentConnectorController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
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

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ContentConnectorId(extractIdFromPath(path));

            auto e = usecase.getContentConnector(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Content connector not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;
            ContentConnectorDTO dto;
            dto.contentConnectorId = ContentConnectorId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.repositoryUrl = j.getString("repositoryUrl");
            dto.branch = j.getString("branch");
            dto.path = j.getString("path");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createContentConnector(dto);
            if (result.success) {
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
            dto.contentConnectorId = ContentConnectorId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.repositoryUrl = j.getString("repositoryUrl");
            dto.branch = j.getString("branch");
            dto.path = j.getString("path");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateContentConnector(dto);
            if (result.success) {
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
            auto contentConnectorId = ContentConnectorId(extractIdFromPath(path));

            auto result = usecase.deleteContentConnector(tenantId, contentConnectorId);
            if (result.success) {
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
