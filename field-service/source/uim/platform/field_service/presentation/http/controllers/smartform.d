/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.smartform;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class SmartformController : ManageController {
    private ManageSmartformsUseCase usecase;

    this(ManageSmartformsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/smartforms", &handleList);
        router.get("/api/v1/field-service/smartforms/*", &handleGet);
        router.post("/api/v1/field-service/smartforms", &handleCreate);
        router.put("/api/v1/field-service/smartforms/*", &handleUpdate);
        router.delete_("/api/v1/field-service/smartforms/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listSmartforms(tenantId);
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
            auto path = precheck.path;
            auto id = SmartformId(precheck.id);

            auto e = usecase.getSmartform(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Smartform not found"); return; }
            res.writeJsonBody(e.toJson, 200);
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
            SmartformDTO dto;
            dto.smartformId = SmartformId(precheck.id);
            dto.tenantId = tenantId;
            dto.serviceCallId = ServiceCallId(data.getString("serviceCallId"));
            dto.activityId = ActivityId(data.getString("activityId"));
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.formType = data.getString("formType");
            dto.templateId = data.getString("templateId");
            dto.safetyLabel = data.getString("safetyLabel");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createSmartform(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Smartform created");

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
            auto path = precheck.path;
            auto data = precheck.data;
            SmartformDTO dto;
            dto.smartformId = SmartformId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.formData = data.getString("formData");
            dto.signatureData = data.getString("signatureData");
            dto.submittedBy = UserId(data.getString("submittedBy"));
            dto.submittedDate = data.getString("submittedDate");
            dto.approvedBy = UserId(data.getString("approvedBy"));
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateSmartform(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Smartform updated");
                  
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
            auto path = precheck.path;
            auto id = SmartformId(precheck.id);
            auto result = usecase.deleteSmartform(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                .set("message", "Smartform deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
