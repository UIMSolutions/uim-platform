/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.dead_letter_entries;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;
import uim.platform.appevents.domain.repositories.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;
import uim.platform.appevents.infrastructure.persistence.memory.dead_letter_entries;
import std.file : mkdirRecurse, write, readText, exists;
import std.path : buildPath, dirName;
import std.conv : to;

@safe:

class FileDeadLetterEntryRepository : MemoryDeadLetterEntryRepository, DeadLetterEntryRepository {
    private string _basePath;

    this(string basePath) @safe {
        _basePath = basePath;
    }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "dead_letter_entries.json");
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
            DeadLetterEntry e;
            e.id = DeadLetterEntryId(jitem["id"].get!string);
            e.tenantId = TenantId(jitem["tenantId"].get!string);
            e.originalMessageId = EventMessageId(jitem["originalMessageId"].get!string);
            e.channelId = EventChannelId(jitem["channelId"].get!string);
            e.errorMessage = jitem["errorMessage"].get!string;
            e.failedAt = jitem["failedAt"].get!long;
            e.retryCount = cast(int)jitem["retryCount"].get!long;
            e.status = jitem["status"].get!string
                .to!DeadLetterStatus;
            e.createdAt = jitem["createdAt"].get!long;
            e.createdBy = UserId(jitem["createdBy"].get!string);
            super.save(e);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(DeadLetterEntry item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(DeadLetterEntry item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, DeadLetterEntryId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
