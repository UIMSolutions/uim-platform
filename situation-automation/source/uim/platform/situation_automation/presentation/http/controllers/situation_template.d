/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_template;
// import uim.platform.situation_automation.application.usecases.manage.situation_templates;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationTemplateController : ManageController {
    private ManageSituationTemplatesUseCase usecase;

    this(ManageSituationTemplatesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/situation-automation/templates", &handleList);
        router.get("/api/v1/situation-automation/templates/*", &handleGet);
        router.post("/api/v1/situation-automation/templates", &handleCreate);
        router.put("/api/v1/situation-automation/templates/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/templates/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateSituationTemplateRequest r;
            r.tenantId = tenantId;
            r.situationTemplateId = precheck.id;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.situationCategory = data.getString("situationCategory").to!SituationCategory;
            r.defaultSeverity = data.getString("defaultSeverity").to!SituationSeverity;
            r.entityTypeId = EntityTypeId(data.getString("entityTypeId"));
            r.sourceSystem = data.getString("sourceSystem");
            r.sourceTemplateId = data.getString("sourceTemplateId");
            r.autoResolveTimeoutMinutes = data.getInteger("autoResolveTimeoutMinutes");
            r.escalationEnabled = data.getBoolean("escalationEnabled");
            r.escalationTargetUserId = data.getString("escalationTargetUserId");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createSituationTemplate(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation template created");

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

            auto templates = usecase.listSituationTemplates(tenantId);

            auto jarr = Json.emptyArray;
            foreach (t; templates) {
                jarr ~= Json.emptyObject
                    .set("id", t.id)
                    .set("name", t.name)
                    .set("description", t.description)
                    .set("category", t.category.to!string)
                    .set("defaultSeverity", t.defaultSeverity.to!string)
                    .set("status", t.status.to!string)
                    .set("entityTypeId", t.entityTypeId)
                    .set("sourceSystem", t.sourceSystem)
                    .set("createdBy", t.createdBy)
                    .set("createdAt", t.createdAt)
                    .set("updatedAt", t.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", templates.length)
                .set("resources", list);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = SituationTemplateId(precheck.id);

            auto t = usecase.getSituationTemplate(tenantId, id);
            if (t.isNull) {
                writeError(res, 404, "Situation template not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", t.id)
                .set("name", t.name)
                .set("description", t.description)
                .set("category", t.category.to!string)
                .set("defaultSeverity", t.defaultSeverity.to!string)
                .set("status", t.status.to!string)
                .set("entityTypeId", t.entityTypeId)
                .set("sourceSystem", t.sourceSystem)
                .set("sourceTemplateId", t.sourceTemplateId)
                .set("autoResolveTimeoutMinutes", t.autoResolveTimeoutMinutes)
                .set("escalationEnabled", t.escalationEnabled)
                .set("escalationTargetUserId", t.escalationTargetUserId)
                .set("createdBy", t.createdBy)
                .set("updatedBy", t.updatedBy)
                .set("createdAt", t.createdAt)
                .set("updatedAt", t.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SituationTemplateId(precheck.id);

            auto data = precheck.data;
            UpdateSituationTemplateRequest r;
            r.tenantId = tenantId;
            r.situationTemplateId = id;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.situationCategory = data.getString("situationCategory").to!SituationCategory;
            r.defaultSeverity = data.getString("defaultSeverity").to!SituationSeverity;
            r.entityTypeId = EntityTypeId(data.getString("entityTypeId"));
            r.autoResolveTimeoutMinutes = data.getInteger("autoResolveTimeoutMinutes");
            r.escalationEnabled = data.getBoolean("escalationEnabled");
            r.escalationTargetUserId = data.getString("escalationTargetUserId");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateSituationTemplate(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation template updated");

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

            auto id = SituationTemplateId(precheck.id);
            auto result = usecase.deleteSituationTemplate(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation template deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
