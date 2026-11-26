/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// KPIs of a tenant (Fiori header, CLI "stats").
module uim.platform.application_events.application.services.statistics;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class AehStatisticsService : IAehStatisticsService {
  protected AehRepositories repos;
  protected IClock clock;

  this(AehRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  AehStatistics compute(TenantId t) {
    AehStatistics s;
    s.tenantId = t;
    auto dayAgo = plusDays(clock.now, -1);
    s.formations = repos.formations.countAll(t);
    foreach (x; repos.systems.findAll(t)) {
      s.systems++;
      if (x.produces)
        s.producers++;
      if (x.consumes)
        s.consumers++;
    }
    foreach (x; repos.topics.findAll(t)) {
      s.topics++;
      if (x.status == TopicStatus.active)
        s.activeTopics++;
    }
    foreach (x; repos.channels.findAll(t)) {
      s.channels++;
      if (x.acceptsMessages)
        s.activeChannels++;
    }
    foreach (x; repos.subscriptions.findAll(t)) {
      s.subscriptions++;
      if (x.isActive)
        s.activeSubscriptions++;
    }
    s.filters = repos.filters.countAll(t);
    bool[string] events;
    foreach (m; repos.messages.findAll(t)) {
      s.messages++;
      if (m.isOpen)
        s.openMessages++;
      if (m.status == MessageStatus.retrying)
        s.retryingMessages++;
      if (m.status == MessageStatus.queued)
        s.queuedMessages++;
      if (m.createdAt >= dayAgo)
        events[m.eventId] = true;
      if (m.status == MessageStatus.delivered && m.deliveredAt >= dayAgo)
        s.deliveredLast24h++;
    }
    s.eventsLast24h = events.length;
    foreach (d; repos.deadLetters.findAll(t)) {
      s.deadLetters++;
      if (d.isOpen)
        s.openDeadLetters++;
    }
    s.users = repos.users.countAll(t);
    return s;
  }
}
