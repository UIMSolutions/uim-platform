/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.event;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class EventApi : IEventApi {
  protected IQueryEnvironmentEventsUseCase usecase;

  this(IQueryEnvironmentEventsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listEvents(string tenantId, string globalAccountId, string subaccountId, string category, string severity) {
    QueryEventsRequest q;
    q.tenantId = tenant(tenantId);
    q.globalAccountId = GlobalAccountId(globalAccountId);
    q.subaccountId = SubaccountId(subaccountId);
    q.category = category;
    q.severity = severity;
    auto items = usecase.queryEvents(q);
    return collectionOf(items);
  }

  Json getEvent(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getEvent(tenant(tenantId), EnvironmentEventId(id)), "Event");
  }
}
