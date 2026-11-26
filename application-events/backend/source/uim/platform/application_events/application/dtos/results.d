/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of publishing, delivery, retention and the demo data.
module uim.platform.application_events.application.dtos.results;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// How one subscription was served by a publish.
struct RouteOutcome {
  EventSubscriptionId subscriptionId;
  string subscriptionName;
  bool routed;
  EventMessageId messageId; /// "" if not routed
  MessageStatus status = MessageStatus.pending; /// after the immediate delivery attempt
  string reason; /// why not routed / dead letter reason / last error
}

struct PublishResult {
  string eventId;
  string eventType;
  string source;
  bool duplicate; /// the event id was published before; nothing was routed again
  bool preview; /// nothing was persisted
  long candidates; /// subscriptions of the producer matching the type
  long routed;
  long filtered; /// rejected by filters
  long skipped; /// paused, inactive systems or channels …
  long delivered; /// delivered immediately
  long queued;
  long retrying;
  long deadLettered;
  RouteOutcome[] outcomes;
  string[] notes; /// e.g. "event type is deprecated"

  string summary() const {
    if (duplicate)
      return "duplicate of event '" ~ eventId ~ "' — nothing routed";
    if (candidates == 0)
      return "no subscription matches '" ~ eventType ~ "' from '" ~ source ~ "'";
    return format("%d of %d subscriptions: %d delivered, %d queued, %d retrying, %d dead letters, %d filtered, %d skipped",
      routed, candidates, delivered, queued, retrying, deadLettered, filtered, skipped);
  }
}

/// Outcome of one delivery attempt.
struct DeliveryResult {
  EventMessageId messageId;
  string subscriptionName;
  string channelName;
  MessageStatus status = MessageStatus.pending;
  int attempts;
  long nextAttemptAt;
  int statusCode;
  string message;
  DeadLetterEntryId deadLetterId; /// set when the message became a dead letter
  bool waiting; /// not attempted: the channel is inactive
}

/// Outcome of a dispatch run over the due messages of a tenant.
struct DispatchSummary {
  long due;
  long attempted;
  long delivered;
  long queued;
  long retrying;
  long deadLettered;
  long dropped;
  long waiting; /// due, but the channel is inactive
  string[] messages;

  void add(const DeliveryResult r) {
    if (r.waiting) {
      waiting++;
      return;
    }
    attempted++;
    final switch (r.status) {
    case MessageStatus.delivered:
      delivered++;
      break;
    case MessageStatus.queued:
      queued++;
      break;
    case MessageStatus.retrying:
      retrying++;
      messages ~= r.subscriptionName ~ ": " ~ r.message;
      break;
    case MessageStatus.deadLettered:
      deadLettered++;
      messages ~= r.subscriptionName ~ ": dead letter — " ~ r.message;
      break;
    case MessageStatus.dropped:
      dropped++;
      messages ~= r.subscriptionName ~ ": dropped — " ~ r.message;
      break;
    case MessageStatus.pending:
      break;
    }
  }
}

struct PurgeResult {
  long messages;
  long deadLetters;
}

struct SeedResult {
  long formations;
  long systems;
  long topics;
  long channels;
  long subscriptions;
  long filters;
  long events;
  long messages;
}

///
unittest {
  DispatchSummary s;
  DeliveryResult r;
  r.status = MessageStatus.delivered;
  s.add(r);
  r.status = MessageStatus.retrying;
  r.subscriptionName = "bp";
  r.message = "HTTP 503";
  s.add(r);
  assert(s.attempted == 2 && s.delivered == 1 && s.retrying == 1 && s.messages == ["bp: HTTP 503"]);
  PublishResult p;
  p.eventType = "a.b";
  p.source = "s4";
  assert(p.summary.canFind("no subscription"));
}
