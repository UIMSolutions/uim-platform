/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.formations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;
import uim.platform.appevents.domain.repositories.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import uim.platform.appevents.infrastructure.persistence.memory.formations;
import std.file  : mkdirRecurse, write, readText, exists;
import std.path  : buildPath, dirName;
import std.conv  : to;

@safe:

class FileFormationRepository
    : MemoryFormationRepository
    , FormationRepository
{
    private string _basePath;

    this(string basePath) @safe { _basePath = basePath; }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "formations.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        auto items = findByTenant(tenantId);
        Json arr = Json.emptyArray;
        foreach (item; items) arr ~= item.toJson();
        write(fp, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        if (!exists(fp)) return;
        auto text = readText(fp);
        auto arr = parseJsonString(text);
        if (arr.type != Json.Type.array) return;
        foreach (jitem; arr.get!(Json[])) {
            Formation f;
            f.id              = FormationId(jitem["id"].get!string);
            f.tenantId        = TenantId(jitem["tenantId"].get!string);
            f.name            = jitem["name"].get!string;
            f.description     = jitem["description"].get!string;
            f.globalAccountId = jitem["globalAccountId"].get!string;
            f.status          = jitem["status"].get!string.to!FormationStatus;
            f.systemCount     = cast(int) jitem["systemCount"].get!long;
            f.createdAt       = jitem["createdAt"].get!long;
            f.updatedAt       = jitem["updatedAt"].get!long;
            f.createdBy       = UserId(jitem["createdBy"].get!string);
            f.updatedBy       = UserId(jitem["updatedBy"].get!string);
            super.save(f);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(Formation item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(Formation item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, FormationId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
