/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.event_subscriptions;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.event_subscription;
// import uim.platform.appevents.domain.repositories.event_subscriptions;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.subscription_status;
// import uim.platform.appevents.infrastructure.persistence.memory.event_subscriptions;
// import std.file : mkdirRecurse, write, readText, exists;
// import std.path : buildPath, dirName;
// 
// import std.array : array;
// import std.algorithm : filter;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

class FileEventSubscriptionRepository : MemoryEventSubscriptionRepository, EventSubscriptionRepository {
    private string _basePath;

    this(string basePath) @safe {
        _basePath = basePath;
    }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "event_subscriptions.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        auto items = findByTenant(tenantId);
        Json arr = Json.emptyArray;
        foreach (item; items)
            arr ~= item.toJson();
        write(fp, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        if (!exists(fp))
            return;
        auto text = readText(fp);
        auto arr = parseJsonString(text);
        if (!arr.isArray)
            return;
        foreach (jitem; arr.get!(Json[])) {
            EventSubscription sub;
            sub.id = EventSubscriptionId(jitem["id"].get!string);
            sub.tenantId = TenantId(jitem["tenantId"].get!string);
            sub.name = jitem["name"].get!string;
            sub.description = jitem["description"].get!string;
            sub.producerSystemId = jitem["producerSystemId"].get!string;
            sub.consumerSystemId = jitem["consumerSystemId"].get!string;
            sub.eventType = jitem["eventType"].get!string;
            sub.status = jitem["status"].get!string
                .to!SubscriptionStatus;
            sub.formationId = FormationId(jitem["formationId"].get!string);
            sub.filterExpression = jitem["filterExpression"].get!string;
            sub.maxRetries = cast(int)jitem["maxRetries"].get!long;
            sub.createdAt = jitem["createdAt"].get!long;
            sub.updatedAt = jitem["updatedAt"].get!long;
            sub.createdBy = UserId(jitem["createdBy"].get!string);
            sub.updatedBy = UserId(jitem["updatedBy"].get!string);
            super.save(sub);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(EventSubscription item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventSubscription item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventSubscriptionId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
