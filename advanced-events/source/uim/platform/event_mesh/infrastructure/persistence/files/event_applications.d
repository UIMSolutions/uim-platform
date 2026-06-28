/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.event_applications;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileEventApplicationRepository : MemoryEventApplicationRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "event_applications.json");
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
            EventApplication e;
            e.id = EventApplicationId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.brokerServiceId = BrokerServiceId(jstr(j, "brokerServiceId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.status = jenum!EventApplicationStatus(j, "status", e.status);
            e.applicationType = jenum!EventApplicationType(j, "applicationType", e.applicationType);
            e.applicationDomainId = jstr(j, "applicationDomainId");
            e.clientUsername = jstr(j, "clientUsername");
            e.clientProfile = jstr(j, "clientProfile");
            e.aclProfile = jstr(j, "aclProfile");
            e.version_ = jstr(j, "version");
            e.protocol = jenum!ProtocolType(j, "protocol", e.protocol);
            e.publishTopics = jstr(j, "publishTopics");
            e.subscribeTopics = jstr(j, "subscribeTopics");
            e.webhookUrl = jstr(j, "webhookUrl");
            e.webhookAuthToken = jstr(j, "webhookAuthToken");
            e.maxConnections = jstr(j, "maxConnections");
            e.currentConnections = jstr(j, "currentConnections");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = Json.emptyArray;
        foreach (item; super.find(tenantId))
            arr ~= item.toJson;
        write(fp, arr.toString());
    }

    override EventApplication[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override EventApplication findById(TenantId tenantId, EventApplicationId id) {
        ensureLoaded(tenantId);
        return super.find(tenantId, id);
    }

    override void save(EventApplication item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventApplication item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventApplicationId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
