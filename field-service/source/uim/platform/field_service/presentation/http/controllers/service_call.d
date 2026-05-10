/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.service_call;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ServiceCallController : PlatformController {
    private ManageServiceCallsUseCase usecase;

    this(ManageServiceCallsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/service-calls", &handleList);
        router.get("/api/v1/field-service/service-calls/*", &handleGet);
        router.post("/api/v1/field-service/service-calls", &handleCreate);
        router.put("/api/v1/field-service/service-calls/*", &handleUpdate);
        router.delete_("/api/v1/field-service/service-calls/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listServiceCalls(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ServiceCallId(extractIdFromPath(path));
            auto serviceCall = usecase.getServiceCall(tenantId, id);
            if (serviceCall.isNull) { writeError(res, 404, "Service call not found"); return; }
            res.writeJsonBody(serviceCall.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ServiceCallDTO dto;
            dto.serviceCallId = ServiceCallId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.customerId = CustomerId(j.getString("customerId"));
            dto.equipmentId = EquipmentId(j.getString("equipmentId"));
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.serviceType = j.getString("serviceType");
            dto.contactPerson = j.getString("contactPerson");
            dto.contactPhone = j.getString("contactPhone");
            dto.contactEmail = j.getString("contactEmail");
            dto.reportedDate = j.getString("reportedDate");
            dto.dueDate = j.getString("dueDate");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createServiceCall(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service call created");

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
            ServiceCallDTO dto;
            dto.serviceCallId = ServiceCallId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.contactPerson = j.getString("contactPerson");
            dto.contactPhone = j.getString("contactPhone");
            dto.contactEmail = j.getString("contactEmail");
            dto.resolution = j.getString("resolution");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateServiceCall(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service call updated");

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
            auto id = ServiceCallId(extractIdFromPath(path));
            
            auto result = usecase.deleteServiceCall(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Service call deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
