/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.alert_event;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class AlertEventController : PlatformController {
    private ProduceEventsUseCase usecase;

    this(ProduceEventsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/alert-notification/events", &handlePost);
    }

    private void handlePost(HTTPServerRequest req, HTTPServerResponse res) @safe {
        
        auto tenantId = req.headers.get("X-Tenant-Id", "default");
        auto body_    = req.json;

        PostAlertEventRequest dto;
        dto.eventType = body_["eventType"].to!string;
        dto.category  = body_["category"].to!string;
        dto.severity  = body_["severity"].to!string;
        dto.subject   = body_["subject"].to!string;
        dto.body      = body_["body"].opt!string("");
        dto.region    = body_["region"].opt!string("");

        auto tagsNode = body_["tags"];
        if (tagsNode.isObject_)
            foreach (k, v; tagsNode.byKeyValue()) dto.tags[k] = v.to!string;

        auto arNode   = body_["affectedResource"];
        if (arNode.isObject_) {
            dto.affectedResource.name      = arNode["name"].opt!string("");
            dto.affectedResource.type_     = arNode["type"].opt!string("");
            dto.affectedResource.instance_ = arNode["instance"].opt!string("");
            auto arTags = arNode["tags"];
            if (arTags.isObject_)
                foreach (k, v; arTags.byKeyValue()) dto.affectedResource.tags[k] = v.to!string;
        }

        auto result = usecase.postEvent(tenantId, dto);
        if (!result.success) { writeError(res, cast(int)HTTPStatus.badRequest, result.message); return; }
        res.writeBody(result.message, cast(int)HTTPStatus.accepted, "application/json");
    }
}
