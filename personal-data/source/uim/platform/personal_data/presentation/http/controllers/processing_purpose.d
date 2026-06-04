/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.processing_purpose;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ProcessingPurposeController : ManageHttpController {
    private ManageProcessingPurposesUseCase usecase;

    this(ManageProcessingPurposesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/personal-data/purposes", &handleList);
        router.get("/api/v1/personal-data/purposes/*", &handleGet);
        router.post("/api/v1/personal-data/purposes", &handleCreate);
        router.put("/api/v1/personal-data/purposes/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/purposes/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateProcessingPurposeRequest r;
            r.tenantId = precheck.tenantId;
            r.id = precheck.id;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.legalBasis = data.getString("legalBasis");
            r.retentionPeriod = data.getString("retentionPeriod");
            r.dataProtectionOfficer = data.getString("dataProtectionOfficer");
            r.requiresConsent = data.getBoolean("requiresConsent");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto purposes = usecase.list(tenantId);

            auto jarr = purposes.map!(p => toJson(p)).array.toJson;

            auto resp = Json.emptyObject
              .set("count", purposes.length)
              .set("resources", jarr)
              .set("message", "Processing purpose list retrieved successfully");

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
            

            auto id = precheck.id;
            auto p = usecase.getById(tenantId, id);
            if (p.isNull) {
                writeError(res, 404, "Processing purpose not found");
                return;
            }
            res.writeJsonBody(toJson(p), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            

            auto data = precheck.data;
            UpdateProcessingPurposeRequest r;
            r.tenantId = precheck.tenantId;
            r.id = precheck.id;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.legalBasis = data.getString("legalBasis");
            r.retentionPeriod = data.getString("retentionPeriod");
            r.dataProtectionOfficer = data.getString("dataProtectionOfficer");
            r.requiresConsent = data.getBoolean("requiresConsent");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose updated");

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
            

            auto id = precheck.id;
            auto result = usecase.deleteProcessingPurpose(id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json purposeToJson(ProcessingPurpose p) {
        return Json.emptyObject
            .set("id", p.id)
            .set("name", p.name)
            .set("description", p.description)
            .set("status", p.status.to!string)
            .set("legalBasis", p.legalBasis.to!string)
            .set("retentionPeriod", p.retentionPeriod)
            .set("dataProtectionOfficer", p.dataProtectionOfficer)
            .set("requiresConsent", p.requiresConsent)
            .set("createdBy", p.createdBy)
            .set("createdAt", p.createdAt);
    }
}
