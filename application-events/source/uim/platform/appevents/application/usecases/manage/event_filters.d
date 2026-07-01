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

@safe:

class ManageEventFiltersUseCase {
    private EventFilterRepository repo;

    this(EventFilterRepository repo) { this.repo = repo; }

    EventFilter getEventFilter(TenantId tenantId, EventFilterId id) {
        return repo.findById(tenantId, id);
    }

    EventFilter[] listEventFilters(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createEventFilter(EventFilterDTO dto) {
        auto f = EventFilter(dto.tenantId, dto.filterId.isNull ? EventFilterId(createId()) : dto.filterId, dto.createdBy);
        f.subscriptionId = dto.subscriptionId;
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        
        repo.save(f);
        return CommandResult(true, f.id.value, "");
    }

    CommandResult updateEventFilter(EventFilterDTO dto) {
        auto f = repo.findById(dto.tenantId, dto.filterId);
        if (f.isNull) return CommandResult(false, "", "Filter not found");
        f.subscriptionId = dto.subscriptionId;
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        if (!dto.updatedBy.isNull) f.updatedBy = dto.updatedBy;
        
        repo.update(f);
        return CommandResult(true, f.id.value, "");
    }

    CommandResult deleteEventFilter(TenantId tenantId, EventFilterId id) {
        auto f = repo.findById(tenantId, id);
        if (f.isNull) return CommandResult(false, "", "Filter not found");

        repo.remove(f);
        return CommandResult(true, f.id.value, "");
    }
}
