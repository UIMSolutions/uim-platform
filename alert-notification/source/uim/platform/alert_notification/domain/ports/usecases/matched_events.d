/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.ports.usecases.matched_events;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

interface IConsumeMatchedEventsUseCase {

    QueryResult listMatchedEvents(TenantId tenantId);

    QueryResult getMatchedEvent(TenantId tenantId, string id);
    
}
