/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.event_channels;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;
import uim.platform.appevents.domain.repositories.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_type;
import uim.platform.appevents.domain.enums.channel_status;
import uim.platform.appevents.domain.enums.delivery_mode;
import uim.platform.appevents.infrastructure.persistence.memory.event_channels;
import std.file  : mkdirRecurse, write, readText, exists;
import std.path  : buildPath, dirName;
import std.conv  : to;

@safe:

class FileEventChannelRepository
    : MemoryEventChannelRepository
    , EventChannelRepository
{
    private string _basePath;

    this(string basePath) @safe { _basePath = basePath; }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "event_channels.json");
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
            EventChannel ch;
            ch.id           = EventChannelId(jitem["id"].get!string);
            ch.tenantId     = TenantId(jitem["tenantId"].get!string);
            ch.name         = jitem["name"].get!string;
            ch.topicId      = EventTopicId(jitem["topicId"].get!string);
            ch.channelType  = jitem["channelType"].get!string.to!ChannelType;
            ch.endpoint     = jitem["endpoint"].get!string;
            ch.status       = jitem["status"].get!string.to!ChannelStatus;
            ch.deliveryMode = jitem["deliveryMode"].get!string.to!DeliveryMode;
            ch.maxSizeBytes = jitem["maxSizeBytes"].get!long;
            ch.createdAt    = jitem["createdAt"].get!long;
            ch.updatedAt    = jitem["updatedAt"].get!long;
            ch.createdBy    = UserId(jitem["createdBy"].get!string);
            ch.updatedBy    = UserId(jitem["updatedBy"].get!string);
            super.save(ch);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(EventChannel item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventChannel item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventChannelId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
