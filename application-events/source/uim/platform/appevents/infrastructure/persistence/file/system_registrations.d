/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.system_registrations;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.system_registration;
// import uim.platform.appevents.domain.repositories.system_registrations;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.system_type;
// import uim.platform.appevents.domain.enums.system_status;
// import uim.platform.appevents.infrastructure.persistence.repositories.system_registrations;
// import std.file  : mkdirRecurse, write, readText, exists;
// import std.path  : buildPath, dirName;
// import std.conv  : to;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

class FileSystemRegistrationRepository
    : MemorySystemRegistrationRepository
    , SystemRegistrationRepository
{
    private string _basePath;

    this(string basePath) @safe { _basePath = basePath; }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "system_registrations.json");
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
        if (!arr.isArray) return;
        foreach (jitem; arr.get!(Json[])) {
            SystemRegistration r;
            r.id           = SystemRegistrationId(jitem["id"].get!string);
            r.tenantId     = TenantId(jitem["tenantId"].get!string);
            r.formationId  = FormationId(jitem["formationId"].get!string);
            r.systemId     = jitem["systemId"].get!string;
            r.systemType   = jitem["systemType"].get!string.to!SystemType;
            r.systemUrl    = jitem["systemUrl"].get!string;
            r.status       = jitem["status"].get!string.to!SystemStatus;
            r.registeredAt = jitem["registeredAt"].get!long;
            r.createdAt    = jitem["createdAt"].get!long;
            r.createdBy    = UserId(jitem["createdBy"].get!string);
            super.save(r);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(SystemRegistration item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(SystemRegistration item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, SystemRegistrationId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
