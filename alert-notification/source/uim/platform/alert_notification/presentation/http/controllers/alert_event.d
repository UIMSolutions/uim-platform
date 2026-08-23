/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.alert_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class AlertEventController : HttpController {
    private ProduceEventsUseCase usecase;

    this(ProduceEventsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/alert-notification/events", &handlePost);
    }

    private void handlePost(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto data = req.json;

        PostAlertEventRequest dto;
        dto.eventType = data.getString("eventType");
        dto.category = data.getString("category");
        dto.severity = data.getString("severity");
        dto.subject = data.getString("subject");
        dto.body = data.getString("body", "");
        dto.region = data.getString("region", "");

        auto tagsNode = data.get("tags", Json.emptyObject);
        if (tagsNode.isObject())
            foreach (k, v; tagsNode.byKeyValue())
                dto.tags[k] = v.to!string;

        auto arNode = data.get("affectedResource", Json.emptyObject);
        if (arNode.isObject()) {
            dto.affectedResource.name = arNode.getString("name", "");
            dto.affectedResource.type_ = arNode.getString("type", "");
            dto.affectedResource.instance_ = arNode.getString("instance", "");
            auto arTags = arNode.get("tags", Json.emptyObject);
            if (arTags.isObject())
                foreach (k, v; arTags.byKeyValue())
                    dto.affectedResource.tags[k] = v.to!string;
        }

        auto result = usecase.postEvent(tenantId, dto);
        if (result.hasError) {
            writeError(res, cast(int)HTTPStatus.badRequest, result.message);
            return;
        }
        res.writeBody(result.message, cast(int)HTTPStatus.accepted, "application/json");
    }
}
