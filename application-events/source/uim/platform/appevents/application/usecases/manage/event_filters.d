/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.repositories.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageEventFiltersUseCase {
    private EventFilterRepository _repo;

    this(EventFilterRepository repo) {
        _repo = repo;
    }

    EventFilter getEventFilter(TenantId tenantId, EventFilterId id) {
        return _repo.findById(tenantId, id);
    }

    EventFilter[] listEventFilters(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    CommandResult createEventFilter(TenantId tenantId, EventFilterDTO dto) {
        EventFilter f;
        f.id = EventFilterId(randomUUID().to!string);
        f.tenantId = tenantId;
        f.subscriptionId = EventSubscriptionId(dto.subscriptionId);
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        _repo.save(tenantId, f);
        return CommandResult(true, f.id.value);
    }

    CommandResult updateEventFilter(TenantId tenantId, EventFilterId id, EventFilterDTO dto) {
        auto f = _repo.findById(tenantId, id);
        if (f.id.isNull) return CommandResult(false, "Filter not found");
        f.subscriptionId = EventSubscriptionId(dto.subscriptionId);
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        _repo.save(tenantId, f);
        return CommandResult(true, id.value);
    }

    CommandResult deleteEventFilter(TenantId tenantId, EventFilterId id) {
        auto f = _repo.findById(tenantId, id);
        if (f.id.isNull) return CommandResult(false, "Filter not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
