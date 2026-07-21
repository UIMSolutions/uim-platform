/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.event_messages;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.event_message;
// import uim.platform.appevents.domain.repositories.event_messages;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.message_status;
// import uim.platform.appevents.infrastructure.persistence.repositories.event_messages;
// import std.file  : mkdirRecurse, write, readText, exists;
// import std.path  : buildPath, dirName;
// import std.conv  : to;
// 
import uim.platform.appevents;

mixin(ShowModule!());

@safe:

class FileEventMessageRepository
    : MemoryEventMessageRepository
    , EventMessageRepository
{
    private string _basePath;

    this(string basePath) @safe { _basePath = basePath; }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "event_messages.json");
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
            EventMessage msg;
            msg.id             = EventMessageId(jitem["id"].get!string);
            msg.tenantId       = TenantId(jitem["tenantId"].get!string);
            msg.channelId      = EventChannelId(jitem["channelId"].get!string);
            msg.eventType      = jitem["eventType"].get!string;
            msg.payload        = jitem["payload"].get!string;
            msg.status         = jitem["status"].get!string.to!MessageStatus;
            msg.sourceSystemId = jitem["sourceSystemId"].get!string;
            msg.targetSystemId = jitem["targetSystemId"].get!string;
            msg.retryCount     = cast(int) jitem["retryCount"].get!long;
            msg.failedReason   = jitem["failedReason"].get!string;
            msg.deliveredAt    = jitem["deliveredAt"].get!long;
            msg.createdAt      = jitem["createdAt"].get!long;
            msg.createdBy      = UserId(jitem["createdBy"].get!string);
            super.save(msg);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(EventMessage item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventMessage item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventMessageId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
