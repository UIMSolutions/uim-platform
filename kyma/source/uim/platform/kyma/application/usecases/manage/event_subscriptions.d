/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.event_subscriptions;

import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.event_subscription;
import uim.platform.kyma.domain.ports.repositories.event_subscriptions;
import uim.platform.kyma.domain.types;

/// Application service for event subscription management.
class ManageEventSubscriptionsUseCase
{
  private EventSubscriptionRepository repo;

  this(EventSubscriptionRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateEventSubscriptionRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Subscription name is required");
    if (req.source.length == 0)
      return CommandResult(false, "", "Event source is required");
    if (req.eventTypes.length == 0)
      return CommandResult(false, "", "At least one event type is required");

    auto existing = repo.findByName(req.namespaceId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Subscription '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    EventSubscription sub;
    sub.id = id;
    sub.namespaceId = req.namespaceId;
    sub.environmentId = req.environmentId;
    sub.tenantId = req.tenantId;
    sub.name = req.name;
    sub.description = req.description;
    sub.status = SubscriptionStatus.pending;
    sub.source = req.source;
    sub.eventTypes = req.eventTypes;
    sub.typeEncoding = parseTypeEncoding(req.typeEncoding);
    sub.sinkUrl = req.sinkUrl;
    sub.sinkServiceName = req.sinkServiceName;
    sub.sinkServicePort = req.sinkServicePort;
    sub.maxInFlightMessages = req.maxInFlightMessages > 0 ? req.maxInFlightMessages : 10;
    sub.exactTypeMatching = req.exactTypeMatching;
    sub.filterAttributes = req.filterAttributes;
    sub.labels = req.labels;
    sub.createdBy = req.createdBy;
    sub.createdAt = clockSeconds();
    sub.modifiedAt = sub.createdAt;

    repo.save(sub);
    return CommandResult(true, id, "");
  }

  CommandResult updateSubscription(EventSubscriptionId id, UpdateEventSubscriptionRequest req)
  {
    auto sub = repo.findById(id);
    if (sub.id.length == 0)
      return CommandResult(false, "", "Subscription not found");

    if (req.description.length > 0)
      sub.description = req.description;
    if (req.eventTypes.length > 0)
      sub.eventTypes = req.eventTypes;
    if (req.sinkUrl.length > 0)
      sub.sinkUrl = req.sinkUrl;
    if (req.sinkServiceName.length > 0)
      sub.sinkServiceName = req.sinkServiceName;
    if (req.sinkServicePort > 0)
      sub.sinkServicePort = req.sinkServicePort;
    if (req.maxInFlightMessages > 0)
      sub.maxInFlightMessages = req.maxInFlightMessages;
    sub.exactTypeMatching = req.exactTypeMatching;
    if (req.filterAttributes !is null)
      sub.filterAttributes = req.filterAttributes;
    if (req.labels !is null)
      sub.labels = req.labels;
    sub.modifiedAt = clockSeconds();

    repo.update(sub);
    return CommandResult(true, id, "");
  }

  CommandResult pauseSubscription(EventSubscriptionId id)
  {
    auto sub = repo.findById(id);
    if (sub.id.length == 0)
      return CommandResult(false, "", "Subscription not found");
    sub.status = SubscriptionStatus.paused;
    sub.modifiedAt = clockSeconds();
    repo.update(sub);
    return CommandResult(true, id, "");
  }

  CommandResult resumeSubscription(EventSubscriptionId id)
  {
    auto sub = repo.findById(id);
    if (sub.id.length == 0)
      return CommandResult(false, "", "Subscription not found");
    sub.status = SubscriptionStatus.active;
    sub.modifiedAt = clockSeconds();
    repo.update(sub);
    return CommandResult(true, id, "");
  }

  EventSubscription getSubscription(EventSubscriptionId id)
  {
    return repo.findById(id);
  }

  EventSubscription[] listByNamespace(NamespaceId nsId)
  {
    return repo.findByNamespace(nsId);
  }

  EventSubscription[] listByEnvironment(KymaEnvironmentId envId)
  {
    return repo.findByEnvironment(envId);
  }

  EventSubscription[] listBySource(string source)
  {
    return repo.findBySource(source);
  }

  CommandResult deleteSubscription(EventSubscriptionId id)
  {
    auto sub = repo.findById(id);
    if (sub.id.length == 0)
      return CommandResult(false, "", "Subscription not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private EventTypeEncoding parseTypeEncoding(string s)
  {
    switch (s)
    {
    case "exact":
      return EventTypeEncoding.exact;
    case "prefix":
      return EventTypeEncoding.prefix;
    default:
      return EventTypeEncoding.exact;
    }
  }
}

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
