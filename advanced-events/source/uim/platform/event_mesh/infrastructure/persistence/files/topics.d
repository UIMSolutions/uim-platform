/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.topics;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileTopicRepository : MemoryTopicRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "topics.json");
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
            Topic e;
            e.id = TopicId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.serviceId = BrokerServiceId(jstr(j, "serviceId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.status = jenum!TopicStatus(j, "status", e.status);
            e.topicString = jstr(j, "topicString");
            e.maxMessageSize = jstr(j, "maxMessageSize");
            e.publishEnabled = jstr(j, "publishEnabled");
            e.subscribeEnabled = jstr(j, "subscribeEnabled");
            e.subscriberCount = jstr(j, "subscriberCount");
            e.publishRate = jstr(j, "publishRate");
            e.subscribeRate = jstr(j, "subscribeRate");
            e.retainedMessage = jstr(j, "retainedMessage");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = super.findByTenant(tenantId).map!(item => item.toJson).array.toJson;
        write(fp, arr.toString());
    }

    override Topic[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override Topic findById(TenantId tenantId, TopicId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(Topic item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(Topic item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, TopicId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
