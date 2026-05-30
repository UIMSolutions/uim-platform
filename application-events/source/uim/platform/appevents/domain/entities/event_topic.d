/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_topic;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;


@safe:

struct EventTopic {
    mixin TenantEntity!(EventTopicId);

    string name;
    string namespace;
    string description;
    string version_;
    string category;
    TopicStatus status;
    string ownerId;

    Json toJson() const @safe {
        return Json.emptyObject
            .set("id",          id.value)
            .set("tenantId",    tenantId.value)
            .set("name",        name)
            .set("namespace",   namespace)
            .set("description", description)
            .set("version",     version_)
            .set("category",    category)
            .set("status",      status.to!string)
            .set("ownerId",     ownerId)
            .set("createdAt",   createdAt)
            .set("createdBy",   createdBy.value)
            .set("updatedAt",   updatedAt)
            .set("updatedBy",   updatedBy.value);
    }
}
