/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Routing of a published event: which subscriptions receive it and why
/// the others do not. Pure — the interactor loads the landscape and
/// persists the resulting messages.
module uim.platform.application_events.domain.services.router;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// The part of the landscape the router needs (looked up by id).
struct RoutingLandscape {
  SystemRegistration[string] systems;
  Formation[string] formations;
  EventChannel[string] channels;
  EventFilter[][string] filters; /// by subscription id
}

/// The decision for one subscription.
struct RouteDecision {
  EventSubscription subscription;
  bool routed; /// a message is created
  bool filtered; /// rejected by a filter
  bool oversized; /// routed, but the payload exceeds the channel limit (→ dead letter)
  string reason; /// why not routed (or the dead letter reason)
}

/// Decide for every subscription of the producer.
RouteDecision[] routeEvent(const CloudEvent e, EventSubscription[] subscriptions, const RoutingLandscape l) @trusted {
  RouteDecision[] result;
  foreach (s; subscriptions) {
    if (s.producerSystemId.value != e.source || !s.matches(e.type))
      continue; // not a candidate at all
    RouteDecision d;
    d.subscription = s;
    d.reason = skipReason(e, s, l);
    if (d.reason.length == 0) {
      auto filters = s.id.value in l.filters;
      auto verdict = evaluateFilters(filters ? *filters : null, e);
      if (!verdict.passed) {
        d.filtered = true;
        d.reason = verdict.reason;
      }
    }
    if (d.reason.length == 0) {
      d.routed = true;
      auto channel = l.channels[s.channelId.value];
      if (e.sizeBytes > channel.maxSizeBytes) {
        d.oversized = true;
        d.reason = format("payload of %d bytes exceeds the limit of channel '%s' (%d bytes)", e.sizeBytes,
          channel.name, channel.maxSizeBytes);
      }
    }
    result ~= d;
  }
  return result;
}

private string skipReason(const CloudEvent e, const EventSubscription s, const RoutingLandscape l) @trusted {
  if (!s.isActive)
    return "subscription is paused";
  auto consumer = s.consumerSystemId.value in l.systems;
  if (consumer is null)
    return "consumer system '" ~ s.consumerSystemId.value ~ "' is not registered";
  if (!consumer.isActive)
    return "consumer system '" ~ consumer.name ~ "' is inactive";
  if (!s.formationId.isNull) {
    auto f = s.formationId.value in l.formations;
    if (f is null || !f.isActive)
      return "formation '" ~ s.formationId.value ~ "' is inactive";
  }
  auto channel = s.channelId.value in l.channels;
  if (channel is null)
    return "channel '" ~ s.channelId.value ~ "' does not exist";
  if (!channel.acceptsMessages)
    return "channel '" ~ channel.name ~ "' is " ~ cast(string) channel.status;
  return "";
}

///
unittest {
  RoutingLandscape l;
  SystemRegistration crm;
  crm.id = SystemRegistrationId("crm");
  crm.name = "CRM";
  l.systems["crm"] = crm;
  EventChannel ch;
  ch.id = EventChannelId("hook");
  ch.name = "hook";
  ch.maxSizeBytes = 1024;
  l.channels["hook"] = ch;

  EventSubscription s;
  s.id = EventSubscriptionId("s1");
  s.producerSystemId = SystemRegistrationId("s4");
  s.consumerSystemId = SystemRegistrationId("crm");
  s.channelId = EventChannelId("hook");
  s.eventType = "sap.bp.*";
  auto other = s;
  other.id = EventSubscriptionId("s2");
  other.eventType = "sap.order.*";
  auto paused = s;
  paused.id = EventSubscriptionId("s3");
  paused.status = SubscriptionStatus.paused;

  CloudEvent e;
  e.type = "sap.bp.Created";
  e.source = "s4";
  e.data = Json(["country": Json("US")]);
  auto d = routeEvent(e, [s, other, paused], l);
  assert(d.length == 2 && d[0].routed && !d[1].routed && d[1].reason == "subscription is paused");

  EventFilter f;
  f.attribute = "data.country";
  f.value = "DE";
  l.filters["s1"] = [f];
  assert(!routeEvent(e, [s], l)[0].routed && routeEvent(e, [s], l)[0].filtered);

  l.filters.remove("s1");
  e.data = Json(["blob": Json("x".replicate(2000))]);
  auto big = routeEvent(e, [s], l)[0];
  assert(big.routed && big.oversized, big.reason);

  e.source = "other";
  assert(routeEvent(e, [s], l).length == 0);
}
