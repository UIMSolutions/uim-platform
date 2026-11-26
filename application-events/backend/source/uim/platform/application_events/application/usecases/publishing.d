/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Publishing of CloudEvents by producer systems.
///
///   1. validate the envelope (CloudEvents 1.0) and the payload size
///   2. the source must be an active producer system; the type must be in
///      the catalog and not retired (requireRegisteredTopics)
///   3. idempotency: an event id already routed for the source is a
///      duplicate — the first result is returned, nothing is routed again
///   4. route (domain service router): subscriptions of the producer whose
///      pattern matches, active, consumer / formation / channel active,
///      filters passed → one message per subscription; payloads above the
///      channel limit become dead letters at once
///   5. deliverOnPublish: the first delivery attempt happens right away
module uim.platform.application_events.application.usecases.publishing;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class PublishEventsUseCase : AehInteractor, IPublishEvents {
  protected DeliveryUseCase delivery;

  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy,
    DeliveryUseCase delivery) {
    super(repos, clock, audit, unitOfWork, policy);
    this.delivery = delivery;
  }

  PublishResult publish(PublishRequest r) {
    return run(r, false);
  }

  PublishResult preview(PublishRequest r) {
    return run(r, true);
  }

  protected PublishResult run(PublishRequest r, bool previewOnly) @trusted {
    auto t = r.tenantId;
    auto e = parseCloudEvent(r.event);
    PublishResult result;
    result.eventId = e.id;
    result.eventType = e.type;
    result.source = e.source;
    result.preview = previewOnly;

    if (e.sizeBytes > policy.maxPayloadBytes)
      throw AehException.invalid(format("The payload has %d bytes (at most %d)", e.sizeBytes, policy.maxPayloadBytes));
    auto producer = repos.systems.findById(t, SystemRegistrationId(e.source));
    if (producer.isNull)
      throw AehException.notFound("Producer system '" ~ e.source ~ "' (the event source)");
    if (!producer.produces)
      throw AehException.ruleViolation("System '" ~ producer.name ~ "' is not a producer");
    if (!producer.isActive)
      throw AehException.ruleViolation("System '" ~ producer.name ~ "' is inactive");
    if (policy.requireRegisteredTopics) {
      auto topics = repos.topics.findByReference(t, "eventType", e.type);
      if (topics.length == 0)
        throw AehException.ruleViolation("Event type '" ~ e.type ~ "' is not registered in the catalog");
      if (!topics[0].acceptsEvents)
        throw AehException.ruleViolation("Event type '" ~ e.type ~ "' is retired");
      if (topics[0].status == TopicStatus.deprecated_)
        result.notes ~= "event type '" ~ e.type ~ "' is deprecated";
      if (!topics[0].ownerSystemId.isNull && topics[0].ownerSystemId != producer.id)
        throw AehException.ruleViolation("Event type '" ~ e.type ~ "' is owned by system '"
            ~ topics[0].ownerSystemId.value ~ "'");
    }

    if (!previewOnly) {
      auto earlier = repos.messages.findByReference(t, "eventId", e.id).filter!(m => m.producerSystemId == producer.id).array;
      if (earlier.length) {
        result.duplicate = true;
        foreach (m; earlier) {
          RouteOutcome o;
          o.subscriptionId = m.subscriptionId;
          o.routed = true;
          o.messageId = m.id;
          o.status = m.status;
          result.outcomes ~= o;
        }
        result.routed = earlier.length;
        result.candidates = earlier.length;
        return result;
      }
    }

    auto decisions = routeEvent(e, repos.subscriptions.findByReference(t, "producerSystemId", producer.id.value),
      landscapeOf(t));
    result.candidates = decisions.length;
    EventMessage[] pending;
    size_t[] pendingOutcome;
    batch(() {
      foreach (d; decisions) {
        RouteOutcome o;
        o.subscriptionId = d.subscription.id;
        o.subscriptionName = d.subscription.name;
        o.routed = d.routed;
        o.reason = d.reason;
        if (!d.routed) {
          if (d.filtered)
            result.filtered++;
          else
            result.skipped++;
          result.outcomes ~= o;
          continue;
        }
        result.routed++;
        if (previewOnly) {
          o.status = d.oversized ? MessageStatus.deadLettered : MessageStatus.pending;
          result.outcomes ~= o;
          continue;
        }
        auto m = newMessage(t, r.actor, e, d.subscription);
        o.messageId = m.id;
        if (d.oversized) {
          delivery.createDeadLetter(m, d.reason);
          result.deadLettered++;
        } else {
          repos.messages.save(m);
          pending ~= m;
          pendingOutcome ~= result.outcomes.length;
        }
        o.status = m.status;
        result.outcomes ~= o;
        auto s = d.subscription;
        s.lastMatchedAt = now;
        repos.subscriptions.save(s);
      }
    });
    if (previewOnly)
      return result;

    foreach (i, m; pending) {
      auto o = &result.outcomes[pendingOutcome[i]];
      if (!policy.deliverOnPublish)
        continue;
      try {
        auto d = delivery.deliverNow(t, m.id, r.actor);
        o.status = d.status;
        if (d.status != MessageStatus.delivered && d.status != MessageStatus.queued)
          o.reason = d.message;
      } catch (EventHubException ex)
        o.reason = ex.msg;
    }
    foreach (o; result.outcomes) {
      if (!o.routed)
        continue;
      switch (o.status) {
      case MessageStatus.delivered:
        result.delivered++;
        break;
      case MessageStatus.queued:
        result.queued++;
        break;
      case MessageStatus.retrying:
        result.retrying++;
        break;
      case MessageStatus.deadLettered:
        if (pending.canFind!(m => m.id == o.messageId))
          result.deadLettered++;
        break;
      default:
        break;
      }
    }
    emit("event.published", t, e.id, Json([
        "type": Json(e.type), "source": Json(e.source), "routed": Json(result.routed),
        "filtered": Json(result.filtered)
      ]));
    return result;
  }

  protected EventMessage newMessage(TenantId t, UserId actor, const CloudEvent e, const EventSubscription s) {
    EventMessage m;
    stampCreated!(EventMessage, EventMessageId)(m, t, actor, newResourceId(), nextTime);
    m.subscriptionId = s.id;
    m.channelId = s.channelId;
    m.producerSystemId = SystemRegistrationId(e.source);
    m.consumerSystemId = s.consumerSystemId;
    m.eventId = e.id;
    m.eventType = e.type;
    m.subject = e.subject;
    m.payload = e.dataText;
    m.contentType = e.dataContentType;
    m.eventTime = e.time > 0 ? e.time : now;
    m.sizeBytes = e.sizeBytes;
    m.maxAttempts = s.maxRetries + 1;
    return m;
  }

  protected RoutingLandscape landscapeOf(TenantId t) {
    RoutingLandscape l;
    foreach (s; repos.systems.findAll(t))
      l.systems[s.id.value] = s;
    foreach (f; repos.formations.findAll(t))
      l.formations[f.id.value] = f;
    foreach (c; repos.channels.findAll(t))
      l.channels[c.id.value] = c;
    foreach (f; repos.filters.findAll(t))
      l.filters[f.subscriptionId.value] ~= f;
    return l;
  }
}
