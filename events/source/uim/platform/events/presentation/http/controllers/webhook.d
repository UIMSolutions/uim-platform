/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class WebhookController : ManageController {
    private ManageWebhooksUseCase usecase;

    this(ManageWebhooksUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/webhooks",    &handleList);
        router.get("/api/v1/sap-event-mesh/webhooks/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/webhooks",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/webhooks/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/webhooks/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listWebhooks(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Webhook list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getWebhook(tenantId, WebhookId(id));
            if (e.isNull) { writeError(res, 404, "Webhook not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Webhook retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            WebhookDTO dto;
            dto.webhookId        = WebhookId(precheck.id);
            dto.tenantId         = tenantId;
            dto.serviceId        = MessagingServiceId(data.getString("serviceId"));
            dto.subscriptionId   = QueueSubscriptionId(data.getString("subscriptionId"));
            dto.name             = data.getString("name");
            dto.description      = data.getString("description");
            dto.url              = data.getString("url");
            dto.headers          = data.getString("headers");
            dto.exemptHandshake  = data.getBoolean("exemptHandshake");
            dto.authenticationType = data.getString("authenticationType");
            dto.credentialsType  = data.getString("credentialsType");
            dto.credentialGrant  = data.getString("credentialGrant");
            dto.tokenUrl         = data.getString("tokenUrl");
            dto.clientId         = data.getString("clientId");
            dto.pushInterval     = data.getString("pushInterval");
            dto.deliveryMode     = data.getString("deliveryMode");
            dto.maxParallelity   = data.getString("maxParallelity");
            dto.createdBy        = UserId(data.getString("createdBy"));
            auto result = usecase.createWebhook(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto webhookId = WebhookId(precheck.id);
            auto data = precheck.data;
            WebhookDTO dto;
            dto.tenantId       = tenantId;
            dto.webhookId      = webhookId;
            dto.url            = data.getString("url");
            dto.description    = data.getString("description");
            dto.headers        = data.getString("headers");
            dto.pushInterval   = data.getString("pushInterval");
            dto.maxParallelity = data.getString("maxParallelity");
            dto.updatedBy      = UserId(data.getString("updatedBy"));
            auto result = usecase.updateWebhook(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = WebhookId(precheck.id);
            auto result = usecase.deleteWebhook(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Webhook deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
