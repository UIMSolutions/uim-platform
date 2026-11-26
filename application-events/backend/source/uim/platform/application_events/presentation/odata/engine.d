/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.application_events.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates EventHubException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

/// A provider over a maintained resource port; rows(t, entities) builds the
/// rows of many entities at once (derived facts are computed once per call).
PortProvider resourceProvider(TEntity, TId, TInput, R)(IManageResource!(TEntity, TId, TInput) port, R rows) {
  auto p = new DelegateEntitySetProvider;
  p.onList = (const RequestContext ctx) => rows(tenantOf(ctx), port.list(tenantOf(ctx)));
  p.onGet = (const RequestContext ctx, string key) => rows(tenantOf(ctx), [port.get(tenantOf(ctx), TId(key))])[0];
  p.onCreate = (const RequestContext ctx, Json payload) => rows(tenantOf(ctx), [
    port.create(createCommandOf!TInput(ctx, payload))
  ])[0];
  p.onUpdate = (const RequestContext ctx, string key, Json payload) => rows(tenantOf(ctx), [
    port.update(updateCommandOf!TInput(ctx, key, payload))
  ])[0];
  p.onRemove = (const RequestContext ctx, string key) { port.remove(tenantOf(ctx), TId(key), actorOf(ctx)); };
  return new PortProvider(p);
}

ODataEngine eventHubEngine(AehPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(eventHubModel());

  // ── lookups ─────────────────────────────────────────────────────────────
  string[string] names(R)(R items) {
    string[string] n;
    foreach (x; items)
      n[x.id.value] = x.name;
    return n;
  }

  string[string] systemNames(TenantId t) {
    return names(ports.systems.list(t));
  }

  /// Message counters by subscription and by channel (open dead letters included).
  void countMessages(TenantId t, out MessageCounts[string] bySubscription, out MessageCounts[string] byChannel) {
    foreach (m; ports.delivery.listMessages(t)) {
      bySubscription.require(m.subscriptionId.value).add(m);
      byChannel.require(m.channelId.value).add(m);
    }
    foreach (d; ports.deadLetters.list(t))
      if (d.isOpen)
        bySubscription.require(d.subscriptionId.value).deadLetters++;
  }

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] formationRows(TenantId t, Formation[] formations) {
    long[string] systems, subscriptions;
    foreach (s; ports.systems.list(t))
      systems[s.formationId.value]++;
    foreach (s; ports.subscriptions.list(t))
      subscriptions[s.formationId.value]++;
    return formations.map!(f => formationRow(f, systems.get(f.id.value, 0), subscriptions.get(f.id.value, 0))).array;
  }

  Json[] systemRows(TenantId t, SystemRegistration[] systems) {
    auto formations = names(ports.formations.list(t));
    long[string] channels, subscriptions, lastEvent;
    foreach (c; ports.channels.list(t))
      channels[c.consumerSystemId.value]++;
    foreach (s; ports.subscriptions.list(t)) {
      subscriptions[s.producerSystemId.value]++;
      if (s.consumerSystemId != s.producerSystemId)
        subscriptions[s.consumerSystemId.value]++;
    }
    foreach (m; ports.delivery.listMessages(t))
      if (m.createdAt > lastEvent.get(m.producerSystemId.value, 0))
        lastEvent[m.producerSystemId.value] = m.createdAt;
    return systems.map!((s) {
      SystemFacts f;
      f.formationName = formations.get(s.formationId.value, "");
      f.channels = channels.get(s.id.value, 0);
      f.subscriptions = subscriptions.get(s.id.value, 0);
      f.lastEventAt = lastEvent.get(s.id.value, 0);
      return systemRow(s, f);
    }).array;
  }

  Json[] topicRows(TenantId t, EventTopic[] topics) {
    auto systems = systemNames(t);
    auto subscriptions = ports.subscriptions.list(t);
    long[string] messages, last;
    foreach (m; ports.delivery.listMessages(t)) {
      messages[m.eventType]++;
      if (m.createdAt > last.get(m.eventType, 0))
        last[m.eventType] = m.createdAt;
    }
    return topics.map!((x) {
      TopicFacts f;
      f.ownerName = systems.get(x.ownerSystemId.value, "");
      f.subscriptions = subscriptions.count!(s => s.matches(x.eventType));
      f.messages = messages.get(x.eventType, 0);
      f.lastPublishedAt = last.get(x.eventType, 0);
      return topicRow(x, f);
    }).array;
  }

  Json[] channelRows(TenantId t, EventChannel[] channels) {
    auto systems = systemNames(t);
    long[string] subscriptions;
    foreach (s; ports.subscriptions.list(t))
      subscriptions[s.channelId.value]++;
    MessageCounts[string] bySubscription, byChannel;
    countMessages(t, bySubscription, byChannel);
    return channels.map!(c => channelRow(c, systems.get(c.consumerSystemId.value, ""), subscriptions.get(c.id.value, 0),
        byChannel.get(c.id.value, MessageCounts.init))).array;
  }

  Json[] subscriptionRows(TenantId t, EventSubscription[] subscriptions) {
    auto systems = systemNames(t);
    auto formations = names(ports.formations.list(t));
    EventChannel[string] channels;
    foreach (c; ports.channels.list(t))
      channels[c.id.value] = c;
    long[string] filters;
    foreach (f; ports.filters.list(t))
      filters[f.subscriptionId.value]++;
    MessageCounts[string] bySubscription, byChannel;
    countMessages(t, bySubscription, byChannel);
    return subscriptions.map!((s) {
      SubscriptionFacts f;
      f.producerName = systems.get(s.producerSystemId.value, "");
      f.consumerName = systems.get(s.consumerSystemId.value, "");
      if (auto c = s.channelId.value in channels) {
        f.channelName = c.name;
        f.channelType = cast(string) c.channelType;
      }
      f.formationName = formations.get(s.formationId.value, "");
      f.filters = filters.get(s.id.value, 0);
      f.messages = bySubscription.get(s.id.value, MessageCounts.init);
      return subscriptionRow(s, f);
    }).array;
  }

  Json[] filterRows(TenantId t, EventFilter[] filters) {
    auto subscriptions = names(ports.subscriptions.list(t));
    return filters.map!(f => filterRow(f, subscriptions.get(f.subscriptionId.value, ""))).array;
  }

  Json[] messageRows(TenantId t, EventMessage[] messages) {
    auto subscriptions = names(ports.subscriptions.list(t));
    auto channels = names(ports.channels.list(t));
    return messages.map!(m => messageRow(m, subscriptions.get(m.subscriptionId.value, ""),
        channels.get(m.channelId.value, ""))).array;
  }

  Json[] deadLetterRows(TenantId t, DeadLetterEntry[] entries) {
    auto subscriptions = names(ports.subscriptions.list(t));
    auto channels = names(ports.channels.list(t));
    string[string] payloads;
    foreach (m; ports.delivery.listMessages(t))
      if (m.status == MessageStatus.deadLettered)
        payloads[m.id.value] = m.payload;
    return entries.map!(d => deadLetterRow(d, subscriptions.get(d.subscriptionId.value, ""),
        channels.get(d.channelId.value, ""), payloads.get(d.messageId.value, ""))).array;
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Formations", resourceProvider(
      cast(IManageResource!(Formation, FormationId, FormationInput)) ports.formations, &formationRows));
  engine.provide("Systems", resourceProvider(
      cast(IManageResource!(SystemRegistration, SystemRegistrationId, SystemInput)) ports.systems, &systemRows));
  engine.provide("EventTypes", resourceProvider(
      cast(IManageResource!(EventTopic, EventTopicId, TopicInput)) ports.topics, &topicRows));
  engine.provide("Channels", resourceProvider(
      cast(IManageResource!(EventChannel, EventChannelId, ChannelInput)) ports.channels, &channelRows));
  engine.provide("Subscriptions", resourceProvider(
      cast(IManageResource!(EventSubscription, EventSubscriptionId, SubscriptionInput)) ports.subscriptions,
      &subscriptionRows));
  engine.provide("Filters", resourceProvider(
      cast(IManageResource!(EventFilter, EventFilterId, FilterInput)) ports.filters, &filterRows));

  auto messages = new DelegateEntitySetProvider;
  messages.onList = (const RequestContext ctx) => messageRows(tenantOf(ctx), ports.delivery.listMessages(tenantOf(ctx)));
  messages.onGet = (const RequestContext ctx, string key) => messageRows(tenantOf(ctx), [
    ports.delivery.getMessage(tenantOf(ctx), EventMessageId(key))
  ])[0];
  engine.provide("Messages", new PortProvider(messages));

  auto deadLetters = new DelegateEntitySetProvider;
  deadLetters.onList = (const RequestContext ctx) => deadLetterRows(tenantOf(ctx), ports.deadLetters.list(tenantOf(ctx)));
  deadLetters.onGet = (const RequestContext ctx, string key) => deadLetterRows(tenantOf(ctx), [
    ports.deadLetters.get(tenantOf(ctx), DeadLetterEntryId(key))
  ])[0];
  engine.provide("DeadLetters", new PortProvider(deadLetters));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto at = clock.now;
    return ports.users.listUsers(tenantOf(ctx)).map!(u => userRow(u, at)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRow(ports.users.getUser(tenantOf(ctx), UserAccountId(key)), clock.now);
  users.onCreate = (const RequestContext ctx, Json p) => userRow(ports.users.createUser(createUserRequest(ctx, p)), clock.now);
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRow(
    ports.users.updateUser(updateUserRequest(ctx, key, p)), clock.now);
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));
  engine.provide("Statistics", new PortProvider(statistics));

  // ── actions ─────────────────────────────────────────────────────────────
  void action(string name, Json delegate(const RequestContext, Json) @safe handler) {
    engine.handle(name, (const RequestContext ctx, Json p) => translated!Json(() => handler(ctx, p)));
  }

  Json one(alias rows, E)(const RequestContext ctx, E e) {
    return rows(tenantOf(ctx), [e])[0];
  }

  action("PublishEvent", (ctx, p) => publishRow(ports.publishing.publish(publishRequestOf(ctx, p))));
  action("PreviewRouting", (ctx, p) => publishRow(ports.publishing.preview(publishRequestOf(ctx, p))));
  action("DispatchDue", (ctx, p) => dispatchRow(ports.delivery.dispatchDue(tenantOf(ctx), actorOf(ctx))));
  action("DeliverMessage", (ctx, p) => deliveryRow(ports.delivery.deliverNow(tenantOf(ctx), EventMessageId(idParam(p)),
      actorOf(ctx))));
  action("AcknowledgeMessage", (ctx, p) => one!messageRows(ctx, ports.delivery.acknowledge(tenantOf(ctx),
      EventMessageId(idParam(p)), actorOf(ctx))));
  action("RequeueDeadLetter", (ctx, p) => deliveryRow(ports.deadLetters.requeue(tenantOf(ctx),
      DeadLetterEntryId(idParam(p)), actorOf(ctx))));
  action("RequeueDeadLetters", (ctx, p) => dispatchRow(ports.deadLetters.requeueAll(tenantOf(ctx),
      EventSubscriptionId(textOf(p, "subscriptionId").strip), actorOf(ctx))));
  action("DiscardDeadLetter", (ctx, p) => one!deadLetterRows(ctx, ports.deadLetters.discard(tenantOf(ctx),
      DeadLetterEntryId(idParam(p)), actorOf(ctx))));
  action("PauseSubscription", (ctx, p) => one!subscriptionRows(ctx, ports.subscriptions.pause(tenantOf(ctx),
      EventSubscriptionId(idParam(p)), actorOf(ctx))));
  action("ResumeSubscription", (ctx, p) => one!subscriptionRows(ctx, ports.subscriptions.resume(tenantOf(ctx),
      EventSubscriptionId(idParam(p)), actorOf(ctx))));
  action("SetChannelStatus", (ctx, p) => one!channelRows(ctx, ports.channels.setStatus(tenantOf(ctx),
      EventChannelId(idParam(p)), parseDomainEnum!ChannelStatus(textOf(p, "status"), "channel status"), actorOf(ctx))));
  action("SetEventTypeStatus", (ctx, p) => one!topicRows(ctx, ports.topics.setStatus(tenantOf(ctx),
      EventTopicId(idParam(p)), parseDomainEnum!TopicStatus(textOf(p, "status"), "event type status"), actorOf(ctx))));
  action("SetSystemStatus", (ctx, p) {
    auto status = parseDomainEnum!SystemStatus(textOf(p, "status"), "system status");
    auto id = SystemRegistrationId(idParam(p));
    auto s = status == SystemStatus.active ? ports.systems.activate(tenantOf(ctx), id, actorOf(ctx))
      : ports.systems.deactivate(tenantOf(ctx), id, actorOf(ctx));
    return one!systemRows(ctx, s);
  });
  action("SetFormationStatus", (ctx, p) {
    auto status = parseDomainEnum!FormationStatus(textOf(p, "status"), "formation status");
    auto id = FormationId(idParam(p));
    auto f = status == FormationStatus.active ? ports.formations.activate(tenantOf(ctx), id, actorOf(ctx))
      : ports.formations.deactivate(tenantOf(ctx), id, actorOf(ctx));
    return one!formationRows(ctx, f);
  });
  action("AssignSystem", (ctx, p) => one!systemRows(ctx, ports.formations.assignSystem(tenantOf(ctx), FormationId(idParam(p)),
      SystemRegistrationId(idParam(p, "systemId")), actorOf(ctx))));
  action("UnassignSystem", (ctx, p) => one!systemRows(ctx, ports.formations.unassignSystem(tenantOf(ctx),
      SystemRegistrationId(idParam(p, "systemId")), actorOf(ctx))));
  action("PurgeMessages", (ctx, p) => purgeRow(ports.delivery.purge(tenantOf(ctx), actorOf(ctx))));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
