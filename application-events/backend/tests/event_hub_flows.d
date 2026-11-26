/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the event flow through
/// the ports (seed → publish → route / filter → deliver → retry with
/// back-off → dead letter → requeue), queue channels (pull / acknowledge),
/// idempotent publishing, the business rules of the landscape, catalog,
/// channels and subscriptions, the REST API and the OData endpoint over
/// vibe.d test requests, the built-in JWT login with scopes, the CLI, the
/// batching file store and the delivery worker.
module tests.event_hub_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.application_events;

@safe:

version (unittest) {
  /// 2026-11-25T10:00:00Z
  long t0() {
    return parseIsoTime("2026-11-25T10:00:00Z");
  }

  struct TestBed {
    AehContainer c;
    ManualClock clock;
    SimulatedDeliveryGateway gateway;
  }

  TestBed newBed(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["dispatchIntervalSeconds"] = 0;
    o["passwordIterations"] = 1000;
    foreach (k, v; extra)
      o[k] = v;
    TestBed b;
    b.clock = new ManualClock(t0);
    b.gateway = new SimulatedDeliveryGateway;
    b.c = new AehContainer(loadAehConfig(o, "/nonexistent"), storage, b.clock, b.gateway);
    b.c.audit.log = false;
    return b;
  }

  /// One HTTP call through the router; text bodies are sent as is.
  Json call(URLRouter router, string method, string path, Json body, out int status, string contentType = "application/json",
    string text = "", string bearer = "", string[string] extraHeaders = null) @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = contentType;
    if (bearer.length)
      headers["Authorization"] = "Bearer " ~ bearer;
    foreach (k, v; extraHeaders)
      headers[k] = v;
    auto payload = text.length ? text : body.type == Json.Type.undefined ? "" : body.toString;
    auto req = createTestHTTPServerRequest(URL("http://localhost" ~ path), httpMethodFromString(method), headers,
      createMemoryStream(cast(ubyte[]) payload.dup, false));
    auto output = createMemoryOutputStream();
    auto res = createTestHTTPServerResponse(output, null, TestHTTPResponseMode.bodyOnly);
    router.handleRequest(req, res);
    status = res.statusCode;
    auto answer = cast(string) output.data;
    if (answer.strip.length == 0)
      return Json(null);
    try
      return parseJsonString(answer);
    catch (Exception)
      return Json(answer);
  }

  URLRouter routerOf(AehContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new AehHealthController(c.config, c.security.mode, c.gateway.mode, c.metrics).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new AehApiController(c.engine, c.ports, c.security, c.config.policy, "/api/v1", "2.0.0", 4 * 1024 * 1024,
      capabilitiesJson(c.gateway.mode, c.config.policy)).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/appevents");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  PublishResult publish(AehContainer c, string type, string source, Json data, string id = "") {
    return c.ports.publishing.publish(publishRequest(t, actor, type, source, data, "", id));
  }

  EventMessage[] messagesOf(AehContainer c, string subscription) {
    return c.ports.delivery.listMessages(t).filter!(m => m.subscriptionId.value == subscription).array;
  }

  /// A minimal landscape: producer p, consumer k (both in formation f),
  /// event type a.b.Created, a webhook channel and one subscription.
  void miniLandscape(AehContainer c, string endpoint = "https://k.example.com/hook", string mode = "atLeastOnce") {
    c.ports.formations.create(createCommand(t, actor, "f", FormationInput("F")));
    c.ports.systems.create(createCommand(t, actor, "p", SystemInput("Producer", "", "producer", "", "f")));
    c.ports.systems.create(createCommand(t, actor, "k", SystemInput("Consumer", "", "consumer", "", "f")));
    c.ports.topics.create(createCommand(t, actor, "ab", TopicInput("a.b.Created", "A created", "", "", "1.0.0", "p")));
    ChannelInput ch;
    ch.name = "hook";
    ch.endpoint = endpoint;
    ch.consumerSystemId = "k";
    ch.deliveryMode = mode;
    c.ports.channels.create(createCommand(t, actor, "hook", ch));
    SubscriptionInput s;
    s.name = "p to k";
    s.producerSystemId = "p";
    s.consumerSystemId = "k";
    s.eventType = "a.b.*";
    s.channelId = "hook";
    s.maxRetries = 2;
    s.retryBackoffSeconds = 10;
    c.ports.subscriptions.create(createCommand(t, actor, "s", s));
  }
}

/// The demo landscape: filters, webhook delivery, queue, retries and dead letters.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto seeded = seedDemoData(c.ports, t, actor);
  assert(seeded.systems == 4 && seeded.topics == 4 && seeded.channels == 3 && seeded.subscriptions == 3);
  assert(seeded.events == 5 && seeded.messages == 4, seeded.to!string); // the US partner is filtered

  // business partners: DE delivered, US filtered, AT (changed) delivered
  auto bp = messagesOf(c, "bp-to-crm");
  assert(bp.length == 2 && bp.all!(m => m.status == MessageStatus.delivered), bp.to!string);
  // sales order: queued for the analytics consumer
  auto orders = messagesOf(c, "orders-to-analytics");
  assert(orders.length == 1 && orders[0].status == MessageStatus.queued);
  // new hire: the onboarding webhook is unreachable → retrying
  auto hires = messagesOf(c, "hires-to-crm");
  assert(hires.length == 1 && hires[0].status == MessageStatus.retrying && hires[0].attempts == 1);
  assert(hires[0].nextAttemptAt == plusSeconds(t0, 30) && hires[0].lastError.canFind("503"));

  // nothing is due before the back-off has passed
  assert(c.ports.delivery.dispatchDue(t, actor).attempted == 0);
  b.clock.advance(30);
  auto run = c.ports.delivery.dispatchDue(t, actor);
  assert(run.attempted == 1 && run.retrying == 1, run.to!string);
  assert(messagesOf(c, "hires-to-crm")[0].nextAttemptAt == plusSeconds(t0, 30 + 60), "back-off doubles");
  b.clock.advance(60);
  run = c.ports.delivery.dispatchDue(t, actor);
  assert(run.deadLettered == 1, run.to!string); // 1 + maxRetries 2 = 3 attempts
  auto letters = c.ports.deadLetters.list(t);
  assert(letters.length == 1 && letters[0].isOpen && letters[0].attempts == 3 && letters[0].reason.canFind("3 attempts"));

  // statistics
  auto s = c.ports.statistics.compute(t);
  assert(s.systems == 4 && s.producers == 2 && s.consumers == 3 && s.subscriptions == 3 && s.filters == 2);
  assert(s.messages == 4 && s.queuedMessages == 1 && s.openDeadLetters == 1 && s.eventsLast24h == 4, s.to!string);
  assert(s.deliveredLast24h == 2);

  // the OData rows carry the health of the subscriptions
  RequestContext ctx;
  ctx.tenantId = "default";
  auto hires2 = c.engine.read(ctx, "Subscriptions", "hires-to-crm");
  assert(hires2["health"].get!string == "error" && hires2["deadLetterCount"].get!long == 1, hires2.toString);
  assert(c.engine.read(ctx, "Subscriptions", "bp-to-crm")["health"].get!string == "ok");

  // the queue consumer pulls and acknowledges
  auto pulled = c.ports.delivery.pull(t, EventChannelId("analytics-queue"), 10, actor);
  assert(pulled.length == 1 && pulled[0].payload.canFind("4711"));
  c.ports.delivery.acknowledge(t, pulled[0].id, actor);
  assert(c.ports.delivery.pull(t, EventChannelId("analytics-queue"), 10, actor).length == 0);
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.delivery.acknowledge(t, pulled[0].id, actor); }));
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.delivery.pull(t, EventChannelId("crm-webhook"), 1, actor); }));

  // fix the endpoint, requeue the dead letter → delivered
  ChannelInput fixed;
  fixed.endpoint = "https://onboarding.example.com/hook";
  c.ports.channels.update(updateCommand(t, actor, "crm-onboarding", fixed, "endpoint"));
  auto requeued = c.ports.deadLetters.requeue(t, letters[0].id, actor);
  assert(requeued.status == MessageStatus.delivered && requeued.attempts == 1, requeued.to!string);
  assert(c.ports.deadLetters.get(t, letters[0].id).status == DeadLetterStatus.requeued);
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.deadLetters.discard(t, letters[0].id, actor); }));
  assert(c.ports.statistics.compute(t).openDeadLetters == 0);

  // a second seed is refused
  assert(failsWith(AehErrorKind.ruleViolation, () { seedDemoData(c.ports, t, actor); }));
}

/// Publishing rules: validation, catalog, idempotency, filters, paused and
/// oversized messages, preview, at-most-once channels.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniLandscape(c);

  // envelope and landscape checks
  assert(failsWith(AehErrorKind.invalid, () { publish(c, "a b", "p", Json(null)); }));
  assert(failsWith(AehErrorKind.notFound, () { publish(c, "a.b.Created", "nobody", Json(null)); }));
  assert(failsWith(AehErrorKind.ruleViolation, () { publish(c, "a.b.Created", "k", Json(null)); }), "consumers do not produce");
  assert(failsWith(AehErrorKind.ruleViolation, () { publish(c, "a.b.Unknown", "p", Json(null)); }), "not in the catalog");

  // routing + immediate delivery
  auto r = publish(c, "a.b.Created", "p", Json(["n": Json(1)]), "evt-1");
  assert(r.routed == 1 && r.delivered == 1 && r.outcomes[0].status == MessageStatus.delivered, r.to!string);
  assert(b.gateway.endpoints == ["https://k.example.com/hook"]);
  // idempotent: the same event id again routes nothing
  auto again = publish(c, "a.b.Created", "p", Json(["n": Json(1)]), "evt-1");
  assert(again.duplicate && again.routed == 1 && b.gateway.attempts == 1 && c.ports.delivery.listMessages(t).length == 1);

  // filters: include + exclude
  FilterInput f;
  f.subscriptionId = "s";
  f.attribute = "data.country";
  f.operator_ = "equals";
  f.value = "DE";
  auto filter = c.ports.filters.create(createCommand(t, actor, "", f));
  assert(publish(c, "a.b.Created", "p", Json(["country": Json("US")])).filtered == 1);
  assert(publish(c, "a.b.Created", "p", Json(["country": Json("DE")])).delivered == 1);
  FilterInput off;
  off.active = false;
  c.ports.filters.update(updateCommand(t, actor, filter.id.value, off, "active"));
  assert(publish(c, "a.b.Created", "p", Json(["country": Json("US")])).routed == 1, "inactive filters are ignored");
  assert(failsWith(AehErrorKind.invalid, () {
      FilterInput bad;
      bad.subscriptionId = "s";
      bad.attribute = "payload.x";
      bad.value = "1";
      c.ports.filters.create(createCommand(t, actor, "", bad));
    }));

  // paused subscription: skipped
  c.ports.subscriptions.pause(t, EventSubscriptionId("s"), actor);
  auto paused = publish(c, "a.b.Created", "p", Json(null));
  assert(paused.skipped == 1 && paused.routed == 0 && paused.outcomes[0].reason == "subscription is paused");
  c.ports.subscriptions.resume(t, EventSubscriptionId("s"), actor);

  // preview persists nothing
  auto before = c.ports.delivery.listMessages(t).length;
  auto preview = c.ports.publishing.preview(publishRequest(t, actor, "a.b.Created", "p", Json(null)));
  assert(preview.preview && preview.routed == 1 && c.ports.delivery.listMessages(t).length == before);

  // oversized payload → dead letter at once
  ChannelInput small;
  small.maxSizeBytes = 1024;
  c.ports.channels.update(updateCommand(t, actor, "hook", small, "maxSizeBytes"));
  auto big = publish(c, "a.b.Created", "p", Json(["blob": Json("x".replicate(2000))]));
  assert(big.deadLettered == 1 && big.outcomes[0].reason.canFind("exceeds"), big.to!string);

  // draining channel: no new messages
  c.ports.channels.setStatus(t, EventChannelId("hook"), ChannelStatus.draining, actor);
  assert(publish(c, "a.b.Created", "p", Json(null)).skipped == 1);
  // inactive channel: due messages wait
  c.ports.channels.setStatus(t, EventChannelId("hook"), ChannelStatus.active, actor);
  b.gateway.failNext = 1;
  auto failing = publish(c, "a.b.Created", "p", Json(null));
  assert(failing.retrying == 1);
  c.ports.channels.setStatus(t, EventChannelId("hook"), ChannelStatus.inactive, actor);
  b.clock.advance(3600);
  auto waiting = c.ports.delivery.dispatchDue(t, actor);
  assert(waiting.waiting == 1 && waiting.attempted == 0 && waiting.delivered == 0, waiting.to!string);

  // retired event types are refused, deprecated ones accepted with a note
  c.ports.channels.setStatus(t, EventChannelId("hook"), ChannelStatus.active, actor);
  c.ports.topics.setStatus(t, EventTopicId("ab"), TopicStatus.deprecated_, actor);
  assert(publish(c, "a.b.Created", "p", Json(null)).notes.length == 1);
  c.ports.topics.setStatus(t, EventTopicId("ab"), TopicStatus.retired, actor);
  assert(failsWith(AehErrorKind.ruleViolation, () { publish(c, "a.b.Created", "p", Json(null)); }));
}

/// At-most-once channels drop failed messages; purge applies the retention.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniLandscape(c, "https://down.invalid/hook", "atMostOnce");
  auto r = publish(c, "a.b.Created", "p", Json(null));
  assert(r.routed == 1 && r.outcomes[0].status == MessageStatus.dropped, r.to!string);
  assert(c.ports.deadLetters.list(t).length == 0);
  assert(c.ports.delivery.purge(t, actor).messages == 0, "within the retention");
  b.clock.advance(73 * 3600);
  assert(c.ports.delivery.purge(t, actor).messages == 1);
  assert(c.ports.delivery.listMessages(t).length == 0);
}

/// Business rules of the landscape, catalog, channels and subscriptions.
unittest {
  auto b = newBed();
  auto c = b.c;
  miniLandscape(c);

  // subscriptions
  SubscriptionInput s;
  s.name = "dup";
  s.producerSystemId = "p";
  s.consumerSystemId = "k";
  s.eventType = "a.b.*";
  s.channelId = "hook";
  assert(failsWith(AehErrorKind.conflict, () { c.ports.subscriptions.create(createCommand(t, actor, "", s)); }));
  s.eventType = "a.b.Unknown";
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.subscriptions.create(createCommand(t, actor, "", s)); }),
    "exact types must be in the catalog");
  s.eventType = "a.b.Created";
  s.producerSystemId = "k";
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.subscriptions.create(createCommand(t, actor, "", s)); }));
  // another formation
  c.ports.systems.create(createCommand(t, actor, "x", SystemInput("Outsider", "", "consumer")));
  ChannelInput xc;
  xc.name = "x";
  xc.channelType = "queue";
  xc.consumerSystemId = "x";
  c.ports.channels.create(createCommand(t, actor, "xq", xc));
  s.producerSystemId = "p";
  s.consumerSystemId = "x";
  s.channelId = "xq";
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.subscriptions.create(createCommand(t, actor, "", s)); }),
    "different formations");
  c.ports.formations.assignSystem(t, FormationId("f"), SystemRegistrationId("x"), actor);
  auto created = c.ports.subscriptions.create(createCommand(t, actor, "sx", s));
  assert(created.formationId.value == "f");
  // a channel of another consumer
  SubscriptionInput wrongChannel;
  wrongChannel.channelId = "hook";
  assert(failsWith(AehErrorKind.ruleViolation, () {
      c.ports.subscriptions.update(updateCommand(t, actor, "sx", wrongChannel, "channelId"));
    }));
  // producer and consumer are immutable
  SubscriptionInput other;
  other.producerSystemId = "k";
  assert(failsWith(AehErrorKind.invalid, () {
      c.ports.subscriptions.update(updateCommand(t, actor, "sx", other, "producerSystemId"));
    }));

  // systems in use
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.systems.remove(t, SystemRegistrationId("p"), actor); }));
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.formations.unassignSystem(t, SystemRegistrationId("x"), actor); }));
  SystemInput role;
  role.systemType = "consumer";
  assert(failsWith(AehErrorKind.ruleViolation, () {
      c.ports.systems.update(updateCommand(t, actor, "p", role, "systemType"));
    }), "a producer of subscriptions keeps its role");
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.formations.remove(t, FormationId("f"), actor); }));

  // topics and channels in use
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.channels.remove(t, EventChannelId("hook"), actor); }));
  assert(failsWith(AehErrorKind.conflict, () {
      c.ports.topics.create(createCommand(t, actor, "", TopicInput("a.b.Created")));
    }));
  TopicInput rename;
  rename.eventType = "a.b.Renamed";
  assert(failsWith(AehErrorKind.invalid, () { c.ports.topics.update(updateCommand(t, actor, "ab", rename, "eventType")); }));
  // channels: consumer must consume, webhooks need endpoints
  ChannelInput bad;
  bad.name = "bad";
  bad.consumerSystemId = "p";
  bad.endpoint = "https://x.example.com";
  assert(failsWith(AehErrorKind.ruleViolation, () { c.ports.channels.create(createCommand(t, actor, "", bad)); }));
  bad.consumerSystemId = "k";
  bad.endpoint = "";
  assert(failsWith(AehErrorKind.invalid, () { c.ports.channels.create(createCommand(t, actor, "", bad)); }));

  // deleting a subscription removes its filters
  FilterInput f;
  f.subscriptionId = "sx";
  f.attribute = "subject";
  f.operator_ = "exists";
  c.ports.filters.create(createCommand(t, actor, "fx", f));
  c.ports.subscriptions.remove(t, EventSubscriptionId("sx"), actor);
  assert(c.ports.filters.list(t).length == 0);

  // inactive formation: events are not routed
  c.ports.formations.deactivate(t, FormationId("f"), actor);
  auto r = publish(c, "a.b.Created", "p", Json(null));
  assert(r.skipped == 1 && r.outcomes[0].reason.canFind("formation"), r.to!string);
}

/// REST API and OData endpoint.
unittest {
  auto b = newBed();
  auto c = b.c;
  auto router = routerOf(c);
  int status;

  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["deliveryGateway"].get!string == "simulate");

  call(router, "POST", "/api/v1/appevents/demo-data", Json.emptyObject, status);
  assert(status == 200, status.to!string);
  auto subs = call(router, "GET", "/api/v1/appevents/subscriptions?$orderby=name", Json.undefined, status);
  assert(status == 200 && subs["count"].get!long == 3, subs.toString);
  auto filters = call(router, "GET", "/api/v1/appevents/subscriptions/bp-to-crm/filters", Json.undefined, status);
  assert(status == 200 && filters["count"].get!long == 2);
  call(router, "GET", "/api/v1/appevents/subscriptions/nope/filters", Json.undefined, status);
  assert(status == 404);

  // structured CloudEvent
  auto event = Json(["specversion": Json("1.0"), "id": Json("rest-1"), "type": Json(orderCreated), "source": Json("s4"),
      "data": Json(["salesOrder": Json("4712")])]);
  auto published = call(router, "POST", "/api/v1/appevents/events", event, status, "application/cloudevents+json");
  assert(status == 202 && published["queued"].get!long == 1 && published["outcomes"][0]["routed"].get!bool, published.toString);
  // binary content mode
  string[string] ce = ["ce-specversion": "1.0", "ce-id": "bin-1", "ce-type": bpCreated, "ce-source": "s4"];
  auto binary = call(router, "POST", "/api/v1/appevents/events", Json.undefined, status, "application/json",
    `{"businessPartner":"7","country":"CH"}`, "", ce);
  assert(status == 202 && binary["delivered"].get!long == 1, binary.toString);
  // batch: one good, one bad event
  auto batch = Json(["events": Json([event, Json(["type": Json("x y"), "source": Json("s4")])])]);
  auto multi = call(router, "POST", "/api/v1/appevents/events", batch, status);
  assert(status == 207 && multi["results"][0]["duplicate"].get!bool && multi["results"][1]["status"].get!long == 400,
    multi.toString);
  // unknown producer → 404, bad JSON → 400
  call(router, "POST", "/api/v1/appevents/events", Json(["type": Json(orderCreated), "source": Json("zz")]), status);
  assert(status == 404);
  call(router, "POST", "/api/v1/appevents/events", Json.undefined, status, "application/json", "{nope");
  assert(status == 400);

  // queue: pull and acknowledge
  auto pulled = call(router, "GET", "/api/v1/appevents/channels/analytics-queue/pull?max=5", Json.undefined, status);
  assert(status == 200 && pulled["count"].get!long == 2, pulled.toString);
  auto id = pulled["resources"][0]["id"].get!string;
  auto acked = call(router, "POST", "/api/v1/appevents/messages/" ~ id ~ "/ack", Json.emptyObject, status);
  assert(status == 200 && acked["status"].get!string == "delivered", acked.toString);

  // dead letters: let the hire fail definitively, then discard via REST
  b.clock.advance(30);
  call(router, "POST", "/api/v1/appevents/delivery/dispatch", Json.emptyObject, status);
  b.clock.advance(60);
  auto run = call(router, "POST", "/api/v1/appevents/delivery/dispatch", Json.emptyObject, status);
  assert(status == 200 && run["deadLettered"].get!long == 1, run.toString);
  auto letters = call(router, "GET", "/api/v1/appevents/dead-letters?$filter=status eq 'open'", Json.undefined, status);
  assert(letters["count"].get!long == 1 && letters["resources"][0]["payload"].get!string.canFind("ada"), letters.toString);
  auto letter = letters["resources"][0]["id"].get!string;
  auto discarded = call(router, "POST", "/api/v1/appevents/dead-letters/" ~ letter ~ "/discard", Json.emptyObject, status);
  assert(status == 200 && discarded["status"].get!string == "discarded");

  // resources: create, PATCH, conflicts, immutables, read-only sets
  auto sys = call(router, "POST", "/api/v1/appevents/systems", Json(["id": Json("ext"), "name": Json("Extension"),
      "systemType": Json("consumer"), "formationId": Json("landscape")]), status);
  assert(status == 201 && sys["formationName"].get!string == "Customer Landscape", sys.toString);
  call(router, "POST", "/api/v1/appevents/systems", Json(["id": Json("ext"), "name": Json("again")]), status);
  assert(status == 409);
  auto patched = call(router, "PATCH", "/api/v1/appevents/systems/ext", Json(["description": Json("BTP app")]), status);
  assert(status == 200 && patched["description"].get!string == "BTP app");
  call(router, "POST", "/api/v1/appevents/messages", Json(["eventType": Json("x")]), status);
  assert(status == 405 || status == 400 || status == 501, status.to!string);
  call(router, "DELETE", "/api/v1/appevents/systems/s4", Json.undefined, status);
  assert(status == 422, "used by subscriptions");
  call(router, "POST", "/api/v1/appevents/subscriptions/bp-to-crm/pause", Json.emptyObject, status);
  assert(status == 200);
  call(router, "POST", "/api/v1/appevents/subscriptions/bp-to-crm/pause", Json.emptyObject, status);
  assert(status == 422);
  auto drained = call(router, "POST", "/api/v1/appevents/channels/crm-webhook/drain", Json.emptyObject, status);
  assert(status == 200 && drained["status"].get!string == "draining");
  auto typed = call(router, "POST", "/api/v1/appevents/event-types/bp-changed/status", Json(["status": Json("deprecated")]),
    status);
  assert(status == 200 && typed["status"].get!string == "deprecated", typed.toString);

  // OData
  auto meta = call(router, "GET", "/odata/v4/appevents/$metadata", Json.undefined, status);
  assert(status == 200 && meta.get!string.canFind(`EntityType Name="Subscription"`));
  auto odata = call(router, "GET", "/odata/v4/appevents/Messages?$filter=status eq 'delivered'&$count=true", Json.undefined,
    status);
  assert(status == 200 && odata["@odata.count"].get!long >= 2, odata.toString);
  auto stats = call(router, "GET", "/odata/v4/appevents/Statistics('default')", Json.undefined, status);
  assert(status == 200 && stats["subscriptions"].get!long == 3 && stats["systems"].get!long == 5, stats.toString);
  auto action = call(router, "POST", "/odata/v4/appevents/PreviewRouting", Json(["type": Json(bpCreated),
      "source": Json("s4"), "data": Json(`{"country":"DE"}`)]), status);
  assert(status == 200 && action["preview"].get!bool && action["skipped"].get!long == 1, action.toString); // paused
  auto stats2 = call(router, "GET", "/api/v1/appevents/statistics", Json.undefined, status);
  assert(status == 200 && stats2["openDeadLetters"].get!long == 0);
  auto caps = call(router, "GET", "/api/v1/appevents/capabilities", Json.undefined, status);
  assert(status == 200 && caps["cloudEvents"].get!string == "1.0");
}

/// Built-in login (authMode jwt): tokens and the scopes Read / Publish / Operate / Manage / Admin.
unittest {
  Json[string] o;
  o["authMode"] = "jwt";
  o["jwtSecret"] = "0123456789abcdef0123456789abcdef-test";
  auto b = newBed(o);
  auto c = b.c;
  assert(c.security.mode == "jwt" && c.security.requireAuthentication);
  assert(c.ports.users.ensureAdministrator(t, "admin", "correct horse battery"));
  assert(!c.ports.users.ensureAdministrator(t, "admin", "correct horse battery"));
  auto router = routerOf(c);
  int status;

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", "/api/v1/appevents/subscriptions", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/appevents/Subscriptions", Json.undefined, status);
  assert(status == 401);
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);

  string login(string user, string password) {
    int s;
    auto r = call(router, "POST", "/auth/login", Json(["username": Json(user), "password": Json(password)]), s);
    assert(s == 200, r.toString);
    return r["access_token"].get!string;
  }

  auto admin = login("admin", "correct horse battery");
  call(router, "POST", "/api/v1/appevents/demo-data", Json.emptyObject, status, "application/json", "", admin);
  assert(status == 200);
  // a producer's technical user may publish but not manage
  call(router, "POST", "/api/v1/appevents/users", Json(["id": Json("s4-tech"), "password": Json("producer secret 1"),
      "scopes": Json([Json("Publish")])]), status, "application/json", "", admin);
  assert(status == 201);
  auto producer = login("s4-tech", "producer secret 1");
  auto event = Json(["type": Json(orderCreated), "source": Json("s4"), "data": Json(["salesOrder": Json("1")])]);
  call(router, "POST", "/api/v1/appevents/events", event, status, "application/json", "", producer);
  assert(status == 202, status.to!string);
  call(router, "POST", "/api/v1/appevents/delivery/dispatch", Json.emptyObject, status, "application/json", "", producer);
  assert(status == 403);
  call(router, "POST", "/api/v1/appevents/systems", Json(["name": Json("x")]), status, "application/json", "", producer);
  assert(status == 403);
  call(router, "GET", "/api/v1/appevents/users", Json.undefined, status, "application/json", "", producer);
  assert(status == 403);
  // a reader may neither publish nor pull
  call(router, "POST", "/api/v1/appevents/users", Json(["id": Json("viewer"), "password": Json("viewer secret 1"),
      "scopes": Json([Json("Read")])]), status, "application/json", "", admin);
  auto viewer = login("viewer", "viewer secret 1");
  call(router, "POST", "/api/v1/appevents/events", event, status, "application/json", "", viewer);
  assert(status == 403);
  call(router, "GET", "/api/v1/appevents/channels/analytics-queue/pull", Json.undefined, status, "application/json", "", viewer);
  assert(status == 403);
  call(router, "GET", "/api/v1/appevents/messages", Json.undefined, status, "application/json", "", viewer);
  assert(status == 200);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", producer);
  assert(status == 200 && me["user"].get!string == "s4-tech" && me["scopes"].length == 2, me.toString);
  // the password of the own account
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("viewer secret 1"),
      "newPassword": Json("viewer secret 2")]), status, "application/json", "", viewer);
  assert(status == 204);
  login("viewer", "viewer secret 2");
  // the last administrator stays
  call(router, "DELETE", "/api/v1/appevents/users/admin", Json.undefined, status, "application/json", "", admin);
  assert(status == 422);
}

/// The command line adapter.
unittest {
  auto b = newBed();
  auto c = b.c;
  string text;
  auto cli = buildAehCli(c, (string s) @safe { text ~= s; });
  assert(cli.run(["seed"]) == 0, text);
  assert(text.canFind("4 systems"), text);
  assert(cli.run(["publish", orderCreated, "s4", `{"salesOrder":"9"}`, "--subject=SalesOrder/9"]) == 0, text);
  assert(text.canFind("queued"), text);
  assert(cli.run(["preview", bpCreated, "s4", `{"country":"US"}`]) == 0 && text.canFind("not routed"), text);
  assert(cli.run(["pull", "analytics-queue"]) == 0 && text.canFind("SalesOrder/9"), text);
  assert(cli.run(["messages", "hires-to-crm"]) == 0 && text.canFind("retrying"), text);
  assert(cli.run(["dead-letters"]) == 0);
  assert(cli.run(["pause", "bp-to-crm"]) == 0 && text.canFind("paused"), text);
  assert(cli.run(["channel-status", "crm-webhook", "draining"]) == 0);
  assert(cli.run(["filters", "bp-to-crm"]) == 0 && text.canFind("data.country oneOf"), text);
  assert(cli.run(["stats"]) == 0 && text.canFind("Subscriptions"), text);
  assert(cli.run(["list", "Subscriptions", "--filter=health eq 'warning'"]) == 0, text);
  assert(cli.run(["deliver", "nope"]) != 0);
}

/// Batching file store: a dispatch run writes the snapshot once; a second
/// container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-aeh-flow-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto store = new BatchingFileDocumentStore(file);
  auto b = newBed(null, StorageSetup(store, store));
  seedDemoData(b.c.ports, t, actor);
  b.clock.advance(30);
  auto before = store.flushes;
  auto run = b.c.ports.delivery.dispatchDue(t, actor);
  assert(run.attempted == 1 && store.flushes == before + 1, format("%s flushes %d → %d", run, before, store.flushes));

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto other = new AehContainer(loadAehConfig(o, "/nonexistent"));
  other.audit.log = false;
  assert(other.ports.subscriptions.list(t).length == 3 && other.ports.delivery.listMessages(t).length == 4);
}

/// The delivery worker never throws and counts its runs.
unittest {
  auto b = newBed();
  seedDemoData(b.c.ports, t, actor);
  auto worker = new DeliveryWorker(b.c.ports, ["default", "other"], 2, b.c.metrics);
  b.clock.advance(30);
  auto s = worker.runOnce();
  assert(s.attempted == 1 && b.c.metrics.runs == 1 && b.c.metrics.retrying == 1, s.to!string);
  worker.runOnce(); // purge run
  assert(b.c.metrics.runs == 2 && b.c.metrics.errors == 0);
}
