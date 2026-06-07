/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.queues;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileQueueRepository : MemoryQueueRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "queues.json");
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
            Queue e;
            e.id = QueueId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.serviceId = BrokerServiceId(jstr(j, "brokerServiceId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.queueType = jenum!QueueType(j, "queueType", e.queueType);
            e.accessType = jenum!QueueAccessType(j, "accessType", e.accessType);
            e.status = jenum!QueueStatus(j, "status", e.status);
            e.maxMsgSpoolUsage = jstr(j, "maxMsgSpoolUsage");
            e.maxBindCount = jstr(j, "maxBindCount");
            e.maxMsgSize = jstr(j, "maxMsgSize");
            e.maxRedeliveryCount = jstr(j, "maxRedeliveryCount");
            e.maxTtl = jstr(j, "maxTtl");
            e.deadMessageQueue = jstr(j, "deadMessageQueue");
            e.owner = jstr(j, "owner");
            e.permission = jstr(j, "permission");
            e.egressEnabled = jstr(j, "egressEnabled");
            e.ingressEnabled = jstr(j, "ingressEnabled");
            e.currentSpoolUsage = jstr(j, "currentSpoolUsage");
            e.messageCount = jstr(j, "messageCount");
            e.bindCount = jstr(j, "bindCount");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = Json.emptyArray;
        foreach (item; super.findByTenant(tenantId))
            arr ~= item.toJson();
        write(fp, arr.toString());
    }

    override Queue[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override Queue findById(TenantId tenantId, QueueId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(Queue item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(Queue item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, QueueId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
