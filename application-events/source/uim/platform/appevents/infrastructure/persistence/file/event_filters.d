/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.repositories.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.filter_type;
import uim.platform.appevents.domain.enums.filter_operator;
import uim.platform.appevents.infrastructure.persistence.memory.event_filters;
import std.file  : mkdirRecurse, write, readText, exists;
import std.path  : buildPath, dirName;
import std.conv  : to;

@safe:

class FileEventFilterRepository
    : MemoryEventFilterRepository
    , EventFilterRepository
{
    private string _basePath;

    this(string basePath) @safe { _basePath = basePath; }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "event_filters.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto fp = filePath(tenantId);
        mkdirRecurse(dirName(fp));
        auto items = find(tenantId);
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
            EventFilter f;
            f.id             = EventFilterId(jitem["id"].get!string);
            f.tenantId       = TenantId(jitem["tenantId"].get!string);
            f.subscriptionId = EventSubscriptionId(jitem["subscriptionId"].get!string);
            f.filterType     = jitem["filterType"].get!string.to!FilterType;
            f.attribute      = jitem["attribute"].get!string;
            f.operator_      = jitem["operator"].get!string.to!FilterOperator;
            f.value          = jitem["value"].get!string;
            f.active         = jitem["active"].get!bool;
            f.createdAt      = jitem["createdAt"].get!long;
            f.createdBy      = UserId(jitem["createdBy"].get!string);
            super.save(f);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(EventFilter item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventFilter item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventFilterId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
