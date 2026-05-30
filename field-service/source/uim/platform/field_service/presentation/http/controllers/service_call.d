/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.service_call;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ServiceCallController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listServiceCalls(tenantId);
            auto list = items.map!(e => e.toJson).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", list);
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ServiceCallId(precheck.id);
            auto serviceCall = usecase.getServiceCall(tenantId, id);
            if (serviceCall.isNull) { writeError(res, 404, "Service call not found"); return; }
            res.writeJsonBody(serviceCall.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            ServiceCallDTO dto;
            dto.serviceCallId = ServiceCallId(precheck.id);
            dto.tenantId = tenantId;
            dto.customerId = CustomerId(data.getString("customerId"));
            dto.equipmentId = EquipmentId(data.getString("equipmentId"));
            dto.subject = data.getString("subject");
            dto.description = data.getString("description");
            dto.serviceType = data.getString("serviceType");
            dto.contactPerson = data.getString("contactPerson");
            dto.contactPhone = data.getString("contactPhone");
            dto.contactEmail = data.getString("contactEmail");
            dto.reportedDate = data.getString("reportedDate");
            dto.dueDate = data.getString("dueDate");
            dto.address = data.getString("address");
            dto.latitude = data.getString("latitude");
            dto.longitude = data.getString("longitude");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createServiceCall(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service call created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            ServiceCallDTO dto;
            dto.serviceCallId = ServiceCallId(precheck.id);
            dto.tenantId = tenantId;
            dto.subject = data.getString("subject");
            dto.description = data.getString("description");
            dto.contactPerson = data.getString("contactPerson");
            dto.contactPhone = data.getString("contactPhone");
            dto.contactEmail = data.getString("contactEmail");
            dto.resolution = data.getString("resolution");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateServiceCall(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service call updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ServiceCallId(precheck.id);
            
            auto result = usecase.deleteServiceCall(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Service call deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
