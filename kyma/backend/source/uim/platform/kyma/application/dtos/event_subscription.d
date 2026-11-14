/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.event_subscription;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct EventSubscriptionSpec {
  string name;
  string description;
  string source;
  string[] eventTypes;
  EventTypeEncoding typeEncoding = EventTypeEncoding.exact;
  /// "" = derived from sinkServiceName / sinkServicePort
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort = 80;
  int maxInFlightMessages = 10;
  KeyValue[] filterAttributes;
  KeyValue[] labels;
}

alias CreateEventSubscriptionRequest = CreateRequest!(NamespaceId, EventSubscriptionSpec);
alias UpdateEventSubscriptionRequest = UpdateRequest!(EventSubscriptionId, EventSubscriptionSpec);
