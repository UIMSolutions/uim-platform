/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.event_filters;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageEventFiltersUseCase {

    EventFilter getEventFilter(TenantId tenantId, EventFilterId id);
    EventFilter[] listEventFilters(TenantId tenantId);
    UsecaseResult createEventFilter(EventFilterDTO dto);
    UsecaseResult updateEventFilter(EventFilterDTO dto);
    UsecaseResult deleteEventFilter(TenantId tenantId, EventFilterId id);

}
