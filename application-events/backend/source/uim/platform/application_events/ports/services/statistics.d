/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.application_events.ports.services.statistics;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct AehStatistics {
  TenantId tenantId;
  long formations;
  long systems;
  long producers;
  long consumers;
  long topics;
  long activeTopics;
  long channels;
  long activeChannels;
  long subscriptions;
  long activeSubscriptions;
  long filters;
  long messages;
  long openMessages; /// pending, retrying or queued
  long retryingMessages;
  long queuedMessages;
  long eventsLast24h; /// distinct events routed
  long deliveredLast24h;
  long deadLetters;
  long openDeadLetters;
  long users;
}

interface IAehStatisticsService {
  AehStatistics compute(TenantId t);
}
