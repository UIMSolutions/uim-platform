/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.application_autoscaler.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates AutoscalerException.
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

ODataEngine autoscalerEngine(AasPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(autoscalerModel());

  // ── lookups ─────────────────────────────────────────────────────────────
  ScalingPolicy[string] policiesOf(TenantId t) {
    ScalingPolicy[string] m;
    foreach (p; ports.policies.list(t))
      m[p.id.value] = p;
    return m;
  }

  ScalingSchedule[][string] schedulesOf(TenantId t) {
    ScalingSchedule[][string] m;
    foreach (s; ports.schedules.list(t))
      m[s.policyId.value] ~= s;
    return m;
  }

  string[string] bindingNames(TenantId t) {
    string[string] n;
    foreach (b; ports.bindings.list(t))
      n[b.id.value] = b.name;
    return n;
  }

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] bindingRows(TenantId t, AppBinding[] bindings) {
    auto policies = policiesOf(t);
    auto schedules = schedulesOf(t);
    long[string] samples, lastMetric, events;
    foreach (m; ports.metrics.list(t)) {
      samples[m.bindingId.value]++;
      if (m.measuredAt > lastMetric.get(m.bindingId.value, 0))
        lastMetric[m.bindingId.value] = m.measuredAt;
    }
    foreach (e; ports.scaling.listEvents(t))
      events[e.bindingId.value]++;
    auto now = clock.now;
    return bindings.map!((b) {
      BindingFacts f;
      f.samples = samples.get(b.id.value, 0);
      f.lastMetricAt = lastMetric.get(b.id.value, 0);
      f.events = events.get(b.id.value, 0);
      if (auto p = b.policyId.value in policies) {
        f.policyName = p.name;
        f.policyStatus = cast(string) p.status;
        auto l = effectiveLimits(*p, schedules.get(p.id.value, null), now);
        f.minInstances = l.min;
        f.maxInstances = l.max;
        f.limitSource = l.source;
      }
      return bindingRow(b, f);
    }).array;
  }

  Json[] policyRows(TenantId t, ScalingPolicy[] policies) {
    long[string] rules, bindings;
    foreach (r; ports.rules.list(t))
      rules[r.policyId.value]++;
    foreach (b; ports.bindings.list(t))
      if (b.hasPolicy)
        bindings[b.policyId.value]++;
    auto schedules = schedulesOf(t);
    auto now = clock.now;
    return policies.map!((p) {
      PolicyFacts f;
      f.rules = rules.get(p.id.value, 0);
      f.bindings = bindings.get(p.id.value, 0);
      auto own = schedules.get(p.id.value, null);
      f.schedules = own.length;
      auto l = effectiveLimits(p, own, now);
      if (!l.scheduleId.isNull)
        f.activeSchedule = l.source;
      return policyRow(p, f);
    }).array;
  }

  Json[] ruleRows(TenantId t, ScalingRule[] rules) {
    auto policies = policiesOf(t);
    return rules.map!(r => ruleRow(r, r.policyId.value in policies ? policies[r.policyId.value].name : "")).array;
  }

  Json[] scheduleRows(TenantId t, ScalingSchedule[] schedules) {
    auto policies = policiesOf(t);
    return schedules.map!((s) {
      auto p = s.policyId.value in policies;
      return scheduleRow(s, p ? p.name : "", p ? p.timezone : "UTC", ports.schedules.isActive(t, s));
    }).array;
  }

  Json[] sampleRows(TenantId t, MetricSample[] samples) {
    auto names = bindingNames(t);
    return samples.map!(m => sampleRow(m, names.get(m.bindingId.value, ""))).array;
  }

  Json[] eventRows(TenantId t, ScalingEvent[] events) {
    auto names = bindingNames(t);
    auto policies = policiesOf(t);
    return events.map!(e => eventRow(e, names.get(e.bindingId.value, ""),
        e.policyId.value in policies ? policies[e.policyId.value].name : "")).array;
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Bindings", resourceProvider(
      cast(IManageResource!(AppBinding, AppBindingId, BindingInput)) ports.bindings, &bindingRows));
  engine.provide("Policies", resourceProvider(
      cast(IManageResource!(ScalingPolicy, ScalingPolicyId, PolicyInput)) ports.policies, &policyRows));
  engine.provide("Rules", resourceProvider(
      cast(IManageResource!(ScalingRule, ScalingRuleId, RuleInput)) ports.rules, &ruleRows));
  engine.provide("Schedules", resourceProvider(
      cast(IManageResource!(ScalingSchedule, ScheduleId, ScheduleInput)) ports.schedules, &scheduleRows));

  auto samples = new DelegateEntitySetProvider;
  samples.onList = (const RequestContext ctx) => sampleRows(tenantOf(ctx), ports.metrics.list(tenantOf(ctx)));
  samples.onGet = (const RequestContext ctx, string key) => sampleRows(tenantOf(ctx), [
    ports.metrics.get(tenantOf(ctx), MetricSampleId(key))
  ])[0];
  samples.onCreate = (const RequestContext ctx, Json p) {
    SubmitMetricRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.bindingId = textOf(p, "bindingId");
    r.metricName = textOf(p, "metricName");
    r.value = doubleOf(p, "value");
    r.unit = textOf(p, "unit");
    r.measuredAt = textOf(p, "measuredAt");
    if (textOf(p, "source").length)
      r.source = textOf(p, "source");
    return sampleRows(tenantOf(ctx), [ports.metrics.submit(r)])[0];
  };
  samples.onRemove = (const RequestContext ctx, string key) {
    ports.metrics.remove(tenantOf(ctx), MetricSampleId(key), actorOf(ctx));
  };
  engine.provide("MetricSamples", new PortProvider(samples));

  auto events = new DelegateEntitySetProvider;
  events.onList = (const RequestContext ctx) => eventRows(tenantOf(ctx), ports.scaling.listEvents(tenantOf(ctx)));
  events.onGet = (const RequestContext ctx, string key) => eventRows(tenantOf(ctx), [
    ports.scaling.getEvent(tenantOf(ctx), ScalingEventId(key))
  ])[0];
  engine.provide("ScalingEvents", new PortProvider(events));

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

  Json bindingOne(const RequestContext ctx, AppBinding b) {
    return bindingRows(tenantOf(ctx), [b])[0];
  }

  Json policyOne(const RequestContext ctx, ScalingPolicy p) {
    return policyRows(tenantOf(ctx), [p])[0];
  }

  action("EvaluateBinding", (ctx, p) => evaluationRow(ports.scaling.evaluate(tenantOf(ctx), AppBindingId(idParam(p)),
      actorOf(ctx))));
  action("PreviewScaling", (ctx, p) {
    auto id = AppBindingId(idParam(p));
    auto d = ports.scaling.preview(tenantOf(ctx), id);
    return previewRow(ports.bindings.get(tenantOf(ctx), id), d);
  });
  action("EvaluateAll", (ctx, p) => summaryRow(ports.scaling.evaluateAll(tenantOf(ctx), actorOf(ctx))));
  action("ScaleBinding", (ctx, p) => evaluationRow(ports.scaling.scaleManually(tenantOf(ctx), AppBindingId(idParam(p)),
      cast(int) longOf(p, "instances"), textOf(p, "reason"), actorOf(ctx))));
  action("SuspendBinding", (ctx, p) => bindingOne(ctx, ports.bindings.suspend(tenantOf(ctx), AppBindingId(idParam(p)),
      actorOf(ctx))));
  action("ResumeBinding", (ctx, p) => bindingOne(ctx, ports.bindings.resume(tenantOf(ctx), AppBindingId(idParam(p)),
      actorOf(ctx))));
  action("AttachPolicy", (ctx, p) => bindingOne(ctx, ports.bindings.attachPolicy(tenantOf(ctx), AppBindingId(idParam(p)),
      ScalingPolicyId(idParam(p, "policyId")), actorOf(ctx))));
  action("DetachPolicy", (ctx, p) => bindingOne(ctx, ports.bindings.detachPolicy(tenantOf(ctx), AppBindingId(idParam(p)),
      actorOf(ctx))));
  action("ActivatePolicy", (ctx, p) => policyOne(ctx, ports.policies.activate(tenantOf(ctx), ScalingPolicyId(idParam(p)),
      actorOf(ctx))));
  action("DeactivatePolicy", (ctx, p) => policyOne(ctx, ports.policies.deactivate(tenantOf(ctx),
      ScalingPolicyId(idParam(p)), actorOf(ctx))));
  action("CopyPolicy", (ctx, p) => policyOne(ctx, ports.policies.copy(tenantOf(ctx), ScalingPolicyId(idParam(p)),
      textOf(p, "newId"), actorOf(ctx))));
  action("SimulateLoad", (ctx, p) {
    SimulateLoadRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.bindingId = idParam(p, "bindingId");
    r.metricName = textOf(p, "metricName");
    r.value = doubleOf(p, "value");
    r.durationSeconds = cast(int) longOf(p, "durationSeconds", 180);
    r.stepSeconds = cast(int) longOf(p, "stepSeconds", 30);
    auto created = ports.metrics.simulate(r);
    return simulationRow(r.bindingId, created.length ? created[0].metricName : r.metricName, r.value, created.length);
  });
  action("PurgeMetrics", (ctx, p) => purgeRow(ports.metrics.purge(tenantOf(ctx), actorOf(ctx))));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
