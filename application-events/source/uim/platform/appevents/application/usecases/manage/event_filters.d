/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.ports.repositories.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.application.dto;

@safe:

class ManageEventFiltersUseCase {
    private IEventFilterRepository repo;

    this(IEventFilterRepository repo) { this.repo = repo; }

    EventFilter getEventFilter(TenantId tenantId, EventFilterId id) {
        return repo.findById(tenantId, id);
    }

    EventFilter[] listEventFilters(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult createEventFilter(EventFilterDTO dto) {
        auto f = EventFilter(dto.tenantId, dto.filterId.isNull ? EventFilterId(createId()) : dto.filterId, dto.createdBy);
        f.subscriptionId = dto.subscriptionId;
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        
        repo.save(f);
        return UsecaseResult(true, f.id.value, "");
    }

    UsecaseResult updateEventFilter(EventFilterDTO dto) {
        auto f = repo.findById(dto.tenantId, dto.filterId);
        if (f.isNull) return UsecaseResult(false, "", "Filter not found");
        f.subscriptionId = dto.subscriptionId;
        f.filterType = dto.filterType;
        f.attribute = dto.attribute;
        f.operator_ = dto.operator_;
        f.value = dto.value;
        f.active = dto.active;
        if (!dto.updatedBy.isNull) f.updatedBy = dto.updatedBy;
        
        repo.update(f);
        return UsecaseResult(true, f.id.value, "");
    }

    UsecaseResult deleteEventFilter(TenantId tenantId, EventFilterId id) {
        auto f = repo.findById(tenantId, id);
        if (f.isNull) return UsecaseResult(false, "", "Filter not found");

        repo.remove(f);
        return UsecaseResult(true, f.id.value, "");
    }
}
