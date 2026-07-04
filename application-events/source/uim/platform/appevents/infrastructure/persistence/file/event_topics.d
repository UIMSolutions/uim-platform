/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.file.event_topics;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.event_topic;
// import uim.platform.appevents.domain.repositories.event_topics;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.topic_status;
// import uim.platform.appevents.infrastructure.persistence.memory.event_topics;
// import std.file  : mkdirRecurse, write, readText, exists;
// import std.path  : buildPath, dirName;
// import std.conv  : to;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

class FileEventTopicRepository : MemoryEventTopicRepository, EventTopicRepository {
    private string _basePath;

    this(string basePath) @safe {
        _basePath = basePath;
    }

    private string filePath(TenantId tenantId) @safe {
        return buildPath(_basePath, tenantId.value, "event_topics.json");
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
            EventTopic t;
            t.id = EventTopicId(jitem["id"].get!string);
            t.tenantId = TenantId(jitem["tenantId"].get!string);
            t.name = jitem["name"].get!string;
            t.namespace = jitem["namespace"].get!string;
            t.description = jitem["description"].get!string;
            t.version_ = jitem["version"].get!string;
            t.category = jitem["category"].get!string;
            t.status = jitem["status"].get!string
                .to!TopicStatus;
            t.ownerId = jitem["ownerId"].get!string;
            t.createdAt = jitem["createdAt"].get!long;
            t.updatedAt = jitem["updatedAt"].get!long;
            t.createdBy = UserId(jitem["createdBy"].get!string);
            t.updatedBy = UserId(jitem["updatedBy"].get!string);
            super.save(t);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(EventTopic item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(EventTopic item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, EventTopicId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }
}
