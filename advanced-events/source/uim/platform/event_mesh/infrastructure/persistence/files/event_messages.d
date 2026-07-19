/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.event_messages;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

mixin(ShowModule!());

@safe:

class FileEventMessageRepository : MemoryEventMessageRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "event_messages.json");
    }

    private void ensureLoaded(TenantId tenantId) {
        if (tenantId in loadedTenants)
            return;
        loadedTenants[tenantId] = true;
        loadTenant(tenantId);
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        if (!fileExists(fp))
            return;

        auto arr = parseJsonString(readText(fp));
        if (!arr.isArray)
            return;

        foreach (j; arr.get!(Json[])) {
            EventMessage e;
            e.id = EventMessageId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.serviceId = BrokerServiceId(jstr(j, "serviceId"));
            e.topicId = TopicId(jstr(j, "topicId"));
            e.queueId = QueueId(jstr(j, "queueId"));
            e.publisherId = EventApplicationId(jstr(j, "publisherId"));
            e.correlationId = jstr(j, "correlationId");
            e.contentType = jstr(j, "contentType");
            e.payload = jstr(j, "payload");
            e.deliveryMode = jenum!DeliveryMode(j, "deliveryMode", e.deliveryMode);
            e.status = jenum!MessageStatus(j, "status", e.status);
            e.priority = jenum!MessagePriority(j, "priority", e.priority);
            e.topicString = jstr(j, "topicString");
            e.replyTo = jstr(j, "replyTo");
            e.timeToLive = jstr(j, "timeToLive");
            e.expiration = jstr(j, "expiration");
            e.sequenceNumber = jstr(j, "sequenceNumber");
            e.redeliveryCount = jstr(j, "redeliveryCount");
            e.dmqEligible = jstr(j, "dmqEligible");
            e.publishTime = jstr(j, "publishTime");
            e.deliveredTime = jstr(j, "deliveredTime");
            e.acknowledgedTime = jstr(j, "acknowledgedTime");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = super.findByTenant(tenantId).map!(item => item.toJson).array.toJson;
        write(fp, arr.toString());
    }

    override EventMessage[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override EventMessage findById(TenantId tenantId, EventMessageId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(EventMessage item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventMessage item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventMessageId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
