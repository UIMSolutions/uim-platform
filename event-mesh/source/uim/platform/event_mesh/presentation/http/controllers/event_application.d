/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_application;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventApplicationController : PlatformController {
    private ManageEventApplicationsUseCase usecase;

    this(ManageEventApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/applications", &handleList);
        router.get("/api/v1/event-mesh/applications/*", &handleGet);
        router.post("/api/v1/event-mesh/applications", &handleCreate);
        router.put("/api/v1/event-mesh/applications/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/applications/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listApplications(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Event application list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventApplicationId(extractIdFromPath(path));
            auto e = usecase.getApplication(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Event application not found");
                return;
            }

            auto resp = e.toJson()
                .set("message", "Event application retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            EventApplicationDTO dto;
            dto.applicationId = EventApplicationId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceId = BrokerServiceId(j.getString("serviceId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.applicationDomainId = j.getString("applicationDomainId");
            dto.clientUsername = j.getString("clientUsername");
            dto.clientProfile = j.getString("clientProfile");
            dto.aclProfile = j.getString("aclProfile");
            dto.version_ = j.getString("version");
            dto.publishTopics = j.getString("publishTopics");
            dto.subscribeTopics = j.getString("subscribeTopics");
            dto.webhookUrl = j.getString("webhookUrl");
            dto.maxConnections = j.getString("maxConnections");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createApplication(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Event application created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            EventApplicationDTO dto;
            dto.applicationId = EventApplicationId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.clientUsername = j.getString("clientUsername");
            dto.clientProfile = j.getString("clientProfile");
            dto.aclProfile = j.getString("aclProfile");
            dto.publishTopics = j.getString("publishTopics");
            dto.subscribeTopics = j.getString("subscribeTopics");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateApplication(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Event application updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventApplicationId(extractIdFromPath(path));

            auto result = usecase.deleteApplication(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Event application deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
