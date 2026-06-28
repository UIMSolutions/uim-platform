/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.event_schemas;

import std.file : fileExists = exists, mkdirRecurse, write, readText;
import std.path : buildPath, dirName;

import vibe.data.json : Json, parseJsonString;

import uim.platform.event_mesh;
import uim.platform.event_mesh.infrastructure.persistence.files.common;

// mixin(ShowModule!());

@safe:

class FileEventSchemaRepository : MemoryEventSchemaRepository {
    private string basePath;
    private bool[TenantId] loadedTenants;

    this(string basePath = "build/data/event-mesh") {
        this.basePath = basePath;
    }

    private string filePath(TenantId tenantId) const {
        return buildPath(basePath, tenantId.value, "event_schemas.json");
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
            EventSchema e;
            e.id = EventSchemaId(jstr(j, "id"));
            e.tenantId = TenantId(jstr(j, "tenantId"));
            e.name = jstr(j, "name");
            e.description = jstr(j, "description");
            e.format = jenum!SchemaFormat(j, "format", e.format);
            e.status = jenum!SchemaStatus(j, "status", e.status);
            e.version_ = jstr(j, "version");
            e.schemaContent = jstr(j, "schemaContent");
            e.applicationDomainId = jstr(j, "applicationDomainId");
            e.shared_ = jstr(j, "shared");
            e.versionCount = jstr(j, "versionCount");
            e.latestVersion = jstr(j, "latestVersion");
            super.save(e);
        }
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        Json arr = super.find(tenantId).map!(item => item.toJson).array.toJson;
        write(fp, arr.toString());
    }

    override EventSchema[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
        ensureLoaded(tenantId);
        return super.findByTenant(tenantId, offset, limit);
    }

    override EventSchema findById(TenantId tenantId, EventSchemaId id) {
        ensureLoaded(tenantId);
        return super.findById(tenantId, id);
    }

    override void save(EventSchema item) {
        ensureLoaded(item.tenantId);
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventSchema item) {
        ensureLoaded(item.tenantId);
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventSchemaId id) {
        ensureLoaded(tenantId);
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
