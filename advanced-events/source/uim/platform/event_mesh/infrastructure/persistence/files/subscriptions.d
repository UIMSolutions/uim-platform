/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.subscriptions;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileSubscriptionRepository : MemorySubscriptionRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "subscriptions.json");
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
            EventSubscription e;
            e.id = EventSubscriptionId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.serviceId = BrokerServiceId(jstr(j, "brokerServiceId"));
            e.topicId = TopicId(jstr(j, "topicId"));
            e.queueId = QueueId(jstr(j, "queueId"));
            e.applicationId = EventApplicationId(jstr(j, "applicationId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.status = jenum!SubscriptionStatus(j, "status", e.status);
            e.subscriptionType = jenum!SubscriptionType(j, "subscriptionType", e.subscriptionType);
            e.deliveryMode = jenum!DeliveryMode(j, "deliveryMode", e.deliveryMode);
            e.topicFilter = jstr(j, "topicFilter");
            e.selector = jstr(j, "selector");
            e.maxRedeliveryCount = jstr(j, "maxRedeliveryCount");
            e.maxTtl = jstr(j, "maxTtl");
            e.lastMessageTime = jstr(j, "lastMessageTime");
            e.messageCount = jstr(j, "messageCount");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = super.find(tenantId).map!(item => item.toJson).array.toJson;
        write(fp, arr.toString());
    }

    override EventSubscription[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override EventSubscription findById(TenantId tenantId, EventSubscriptionId id) {
        ensureLoaded(tenantId);
        return super.find(tenantId, id);
    }

    override void save(EventSubscription item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventSubscription item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventSubscriptionId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
