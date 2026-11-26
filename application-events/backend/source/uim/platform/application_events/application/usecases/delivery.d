/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Delivery of messages and the dead letters.
///
///   webhook channel  an attempt POSTs the CloudEvent (IDeliveryGateway);
///                    success → delivered; failure → retrying with
///                    exponential back-off, after the last attempt a dead
///                    letter (at-most-once: dropped)
///   queue channel    an attempt puts the message into the queue (queued);
///                    the consumer pulls it and acknowledges (delivered)
///   inactive channel messages wait (pending); draining channels deliver
///
/// Dead letters are requeued (attempts start again) or discarded.
module uim.platform.application_events.application.usecases.delivery;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum size_t maxPull = 100;

class DeliveryUseCase : AehInteractor, IDeliverMessages, IManageDeadLetters {
  protected IDeliveryGateway gateway;

  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy,
    IDeliveryGateway gateway) {
    super(repos, clock, audit, unitOfWork, policy);
    this.gateway = gateway;
  }

  // ── IDeliverMessages ──────────────────────────────────────────────────────

  DispatchSummary dispatchDue(TenantId t, UserId actor) {
    DispatchSummary summary;
    auto at = now;
    auto due = repos.messages.findByStatus(t, [MessageStatus.pending, MessageStatus.retrying]).filter!(m => m.isDueAt(at))
      .array;
    summary.due = due.length;
    if (due.length > policy.maxDispatchBatch)
      due = due[0 .. policy.maxDispatchBatch];
    EventChannel[string] channels;
    EventSubscription[string] subscriptions;
    batch(() {
      foreach (m; due)
        summary.add(attempt(m, channels, subscriptions));
    });
    return summary;
  }

  DeliveryResult deliverNow(TenantId t, EventMessageId id, UserId actor) {
    auto m = getMessage(t, id);
    if (m.status == MessageStatus.queued)
      throw AehException.ruleViolation("Message '" ~ id.value ~ "' is queued — the consumer acknowledges it");
    if (!m.isOpen)
      throw AehException.ruleViolation("Message '" ~ id.value ~ "' is " ~ cast(string) m.status);
    EventChannel[string] channels;
    EventSubscription[string] subscriptions;
    DeliveryResult r;
    batch(() { r = attempt(m, channels, subscriptions); });
    return r;
  }

  EventMessage[] pull(TenantId t, EventChannelId channelId, size_t max, UserId actor) {
    auto channel = channelOf(t, channelId);
    if (!channel.isQueue)
      throw AehException.ruleViolation("Channel '" ~ channel.name ~ "' is a webhook — messages are pushed, not pulled");
    auto queued = repos.messages.findByReference(t, "channelId", channelId.value).filter!(
      m => m.status == MessageStatus.queued).array;
    auto n = max == 0 ? 10 : max > maxPull ? maxPull : max;
    return queued.length > n ? queued[0 .. n] : queued;
  }

  EventMessage acknowledge(TenantId t, EventMessageId id, UserId actor) {
    auto m = getMessage(t, id);
    if (m.status != MessageStatus.queued)
      throw AehException.ruleViolation("Message '" ~ id.value ~ "' is " ~ cast(string) m.status ~ ", not queued");
    m.status = MessageStatus.delivered;
    m.deliveredAt = now;
    stampUpdated(m, actor, now);
    repos.messages.save(m);
    emit("message.acknowledged", t, id.value, Json(["channel": Json(m.channelId.value)]));
    return m;
  }

  EventMessage getMessage(TenantId t, EventMessageId id) {
    return required(repos.messages.findById(t, id), "Message '" ~ id.value ~ "'");
  }

  EventMessage[] listMessages(TenantId t) {
    return repos.messages.findAll(t);
  }

  PurgeResult purge(TenantId t, UserId actor) {
    PurgeResult r;
    auto at = now;
    auto messageCutoff = plusSeconds(at, -policy.messageRetentionHours * 3600);
    auto letterCutoff = plusDays(at, -policy.deadLetterRetentionDays);
    batch(() {
      bool[string] keep; // messages of open dead letters
      foreach (d; repos.deadLetters.findAll(t)) {
        if (d.isOpen)
          keep[d.messageId.value] = true;
        else if (d.resolvedAt > 0 && d.resolvedAt < letterCutoff && repos.deadLetters.removeById(t, d.id))
          r.deadLetters++;
      }
      foreach (m; repos.messages.findByStatus(t, [
          MessageStatus.delivered, MessageStatus.dropped, MessageStatus.deadLettered
        ]))
        if (m.updatedAt < messageCutoff && m.id.value !in keep && repos.messages.removeById(t, m.id))
          r.messages++;
    });
    if (r.messages + r.deadLetters > 0)
      emit("messages.purged", t, "", Json(["messages": Json(r.messages), "deadLetters": Json(r.deadLetters)]));
    return r;
  }

  // ── IManageDeadLetters ────────────────────────────────────────────────────

  DeadLetterEntry get(TenantId t, DeadLetterEntryId id) {
    return required(repos.deadLetters.findById(t, id), "Dead letter '" ~ id.value ~ "'");
  }

  DeadLetterEntry[] list(TenantId t) {
    return repos.deadLetters.findAll(t);
  }

  DeliveryResult requeue(TenantId t, DeadLetterEntryId id, UserId actor) {
    EventChannel[string] channels;
    EventSubscription[string] subscriptions;
    DeliveryResult r;
    batch(() { r = requeueOne(get(t, id), actor, channels, subscriptions); });
    return r;
  }

  DispatchSummary requeueAll(TenantId t, EventSubscriptionId subscription, UserId actor) {
    DispatchSummary s;
    EventChannel[string] channels;
    EventSubscription[string] subscriptions;
    batch(() {
      foreach (d; repos.deadLetters.findAll(t)) {
        if (!d.isOpen || (!subscription.isNull && d.subscriptionId != subscription))
          continue;
        s.due++;
        if (repos.messages.existsById(t, d.messageId))
          s.add(requeueOne(d, actor, channels, subscriptions));
      }
    });
    return s;
  }

  DeadLetterEntry discard(TenantId t, DeadLetterEntryId id, UserId actor) {
    auto d = get(t, id);
    if (!d.isOpen)
      throw AehException.ruleViolation("Dead letter '" ~ id.value ~ "' is already " ~ cast(string) d.status);
    d.status = DeadLetterStatus.discarded;
    d.resolvedAt = now;
    d.resolvedBy = actor.value;
    stampUpdated(d, actor, now);
    repos.deadLetters.save(d);
    emit("deadLetter.discarded", t, id.value, Json(["message": Json(d.messageId.value)]));
    return d;
  }

  // ── delivery ──────────────────────────────────────────────────────────────

  protected DeliveryResult requeueOne(DeadLetterEntry d, UserId actor, ref EventChannel[string] channels,
    ref EventSubscription[string] subscriptions) {
    auto t = d.tenantId;
    if (!d.isOpen)
      throw AehException.ruleViolation("Dead letter '" ~ d.id.value ~ "' is already " ~ cast(string) d.status);
    auto m = repos.messages.findById(t, d.messageId);
    if (m.isNull)
      throw AehException.ruleViolation("The message of dead letter '" ~ d.id.value ~ "' was purged");
    d.status = DeadLetterStatus.requeued;
    d.resolvedAt = now;
    d.resolvedBy = actor.value;
    stampUpdated(d, actor, now);
    repos.deadLetters.save(d);
    m.status = MessageStatus.pending;
    m.attempts = 0;
    m.nextAttemptAt = 0;
    m.lastError = "";
    stampUpdated(m, actor, now);
    emit("deadLetter.requeued", t, d.id.value, Json(["message": Json(m.id.value)]));
    return attempt(m, channels, subscriptions);
  }

  /// One attempt; persists the message (and a dead letter if it gives up).
  protected DeliveryResult attempt(EventMessage m, ref EventChannel[string] channels,
    ref EventSubscription[string] subscriptions) @trusted {
    auto t = m.tenantId;
    auto at = now;
    if (m.channelId.value !in channels)
      channels[m.channelId.value] = repos.channels.findById(t, m.channelId);
    if (m.subscriptionId.value !in subscriptions)
      subscriptions[m.subscriptionId.value] = repos.subscriptions.findById(t, m.subscriptionId);
    auto channel = channels[m.channelId.value];
    auto sub = subscriptions[m.subscriptionId.value];

    DeliveryResult r;
    r.messageId = m.id;
    r.subscriptionName = sub.isNull ? m.subscriptionId.value : sub.name;
    r.channelName = channel.isNull ? m.channelId.value : channel.name;

    if (channel.isNull) {
      m.attempts++;
      return giveUp(m, r, "channel '" ~ m.channelId.value ~ "' no longer exists");
    }
    if (!channel.delivers) {
      r.status = m.status;
      r.waiting = true;
      r.message = "channel '" ~ channel.name ~ "' is inactive";
      return r;
    }
    m.lastAttemptAt = at;
    m.updatedAt = at;
    if (channel.isQueue) {
      m.attempts++;
      m.status = MessageStatus.queued;
      m.lastError = "";
      repos.messages.save(m);
      r.status = m.status;
      r.attempts = m.attempts;
      r.message = "queued in '" ~ channel.name ~ "'";
      return r;
    }

    auto outcome = gateway.deliver(channel, m);
    m.attempts++;
    r.attempts = m.attempts;
    r.statusCode = outcome.statusCode;
    if (outcome.success) {
      m.status = MessageStatus.delivered;
      m.deliveredAt = at;
      m.lastError = "";
      repos.messages.save(m);
      r.status = m.status;
      r.message = outcome.message.length ? outcome.message : "delivered";
      emit("message.delivered", t, m.id.value, Json(["channel": Json(channel.id.value), "attempts": Json(m.attempts)]));
      return r;
    }

    m.lastError = outcome.message.length ? outcome.message : "delivery failed";
    final switch (afterFailure(channel.deliveryMode, m.attempts, m.maxAttempts)) {
    case FailureOutcome.retry:
      auto base = sub.isNull ? 30 : sub.retryBackoffSeconds;
      m.status = MessageStatus.retrying;
      m.nextAttemptAt = plusSeconds(at, backoffSeconds(m.attempts, base, policy.maxBackoffSeconds));
      repos.messages.save(m);
      r.status = m.status;
      r.nextAttemptAt = m.nextAttemptAt;
      r.message = m.lastError ~ format(" (attempt %d of %d)", m.attempts, m.maxAttempts);
      emit("message.failed", t, m.id.value, Json(["attempts": Json(m.attempts), "error": Json(m.lastError)]));
      return r;
    case FailureOutcome.deadLetter:
      return giveUp(m, r, format("delivery failed after %d attempts: %s", m.attempts, m.lastError));
    case FailureOutcome.drop:
      m.status = MessageStatus.dropped;
      repos.messages.save(m);
      r.status = m.status;
      r.message = m.lastError ~ " (at-most-once: dropped)";
      emit("message.dropped", t, m.id.value, Json(["error": Json(m.lastError)]));
      return r;
    }
  }

  /// Make the message a dead letter.
  protected DeliveryResult giveUp(ref EventMessage m, DeliveryResult r, string reason) {
    auto entry = createDeadLetter(m, reason);
    r.status = m.status;
    r.attempts = m.attempts;
    r.message = reason;
    r.deadLetterId = entry.id;
    return r;
  }

  /// Persist a dead letter for the message (status deadLettered).
  DeadLetterEntry createDeadLetter(ref EventMessage m, string reason) {
    m.status = MessageStatus.deadLettered;
    m.lastError = reason;
    m.updatedAt = now;
    repos.messages.save(m);
    DeadLetterEntry d;
    stampCreated!(DeadLetterEntry, DeadLetterEntryId)(d, m.tenantId, UserId(workerActor), newResourceId(), nextTime);
    d.messageId = m.id;
    d.subscriptionId = m.subscriptionId;
    d.channelId = m.channelId;
    d.eventId = m.eventId;
    d.eventType = m.eventType;
    d.reason = reason;
    d.attempts = m.attempts;
    repos.deadLetters.save(d);
    emit("message.deadLettered", m.tenantId, m.id.value, Json(["deadLetter": Json(d.id.value), "reason": Json(reason)]));
    return d;
  }
}
