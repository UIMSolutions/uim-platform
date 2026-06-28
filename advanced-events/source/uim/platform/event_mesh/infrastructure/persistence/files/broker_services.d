/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.broker_services;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileBrokerServiceRepository : MemoryBrokerServiceRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "broker_services.json");
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
            BrokerService e;
            e.id = BrokerServiceId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.status = jenum!BrokerServiceStatus(j, "status", e.status);
            e.serviceType = jenum!BrokerServiceType(j, "serviceType", e.serviceType);
            e.serviceClass = jenum!BrokerServiceClass(j, "serviceClass", e.serviceClass);
            e.cloudProvider = jenum!CloudProvider(j, "cloudProvider", e.cloudProvider);
            e.region = jstr(j, "region");
            e.datacenter = jstr(j, "datacenter");
            e.version_ = jstr(j, "version");
            e.maxConnections = jstr(j, "maxConnections");
            e.maxQueueDepth = jstr(j, "maxQueueDepth");
            e.maxMessageSize = jstr(j, "maxMessageSize");
            e.msgVpnName = jstr(j, "msgVpnName");
            e.smfHost = jstr(j, "smfHost");
            e.smfPort = jstr(j, "smfPort");
            e.mqttHost = jstr(j, "mqttHost");
            e.mqttPort = jstr(j, "mqttPort");
            e.amqpHost = jstr(j, "amqpHost");
            e.amqpPort = jstr(j, "amqpPort");
            e.restHost = jstr(j, "restHost");
            e.restPort = jstr(j, "restPort");
            e.webSocketHost = jstr(j, "webSocketHost");
            e.webSocketPort = jstr(j, "webSocketPort");
            e.adminUrl = jstr(j, "adminUrl");
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

    override BrokerService[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override BrokerService findById(TenantId tenantId, BrokerServiceId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(BrokerService item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(BrokerService item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, BrokerServiceId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
