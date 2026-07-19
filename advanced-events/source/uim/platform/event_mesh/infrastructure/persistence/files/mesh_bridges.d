/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.mesh_bridges;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;
mixin(ShowModule!());

@safe:

class FileMeshBridgeRepository : MemoryMeshBridgeRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "mesh_bridges.json");
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
            MeshBridge e;
            e.id = MeshBridgeId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.sourceServiceId = BrokerServiceId(jstr(j, "sourceBrokerServiceId", jstr(j, "sourceServiceId")));
            e.targetServiceId = BrokerServiceId(jstr(j, "targetBrokerServiceId", jstr(j, "targetServiceId")));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.status = jenum!BridgeStatus(j, "status", e.status);
            e.bridgeType = jenum!BridgeType(j, "bridgeType", e.bridgeType);
            e.remoteAddress = jstr(j, "remoteAddress");
            e.remoteVpnName = jstr(j, "remoteVpnName");
            e.topicSubscriptions = jstr(j, "topicSubscriptions");
            e.queueBindings = jstr(j, "queueBindings");
            e.tlsEnabled = jstr(j, "tlsEnabled");
            e.compressedDataEnabled = jstr(j, "compressedDataEnabled");
            e.maxTtl = jstr(j, "maxTtl");
            e.retryCount = jstr(j, "retryCount");
            e.retryDelay = jstr(j, "retryDelay");
            e.egressFlowWindowSize = jstr(j, "egressFlowWindowSize");
            e.uplinkThroughput = jstr(j, "uplinkThroughput");
            e.downlinkThroughput = jstr(j, "downlinkThroughput");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = super.findByTenant(tenantId).map!(item => item.toJson).array.toJson;
        write(fp, arr.toString());
    }

    override MeshBridge[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override MeshBridge findById(TenantId tenantId, MeshBridgeId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(MeshBridge item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(MeshBridge item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, MeshBridgeId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
