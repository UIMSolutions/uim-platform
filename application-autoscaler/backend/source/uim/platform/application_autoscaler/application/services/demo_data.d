/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content of an empty tenant (Fiori "Create Demo Content", CLI
/// "seed"): three policies with rules and schedules, five bindings and
/// recent metric samples — one binding is hot, so the next evaluation
/// scales it out. Everything goes through the driving ports, so the
/// business rules apply.
module uim.platform.application_autoscaler.application.services.demo_data;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(AasPorts ports, TenantId t, UserId actor) {
  if (ports.bindings.list(t).length || ports.policies.list(t).length)
    throw AasException.ruleViolation("Demo content is only created in an empty tenant");
  SeedResult r;

  ScalingPolicy policy(string id, string name, string description, int min, int max, string tz, string allow) {
    PolicyInput i;
    i.name = name;
    i.description = description;
    i.instanceMinCount = min;
    i.instanceMaxCount = max;
    i.timezone = tz;
    i.customMetricAllowFrom = allow;
    r.policies++;
    return ports.policies.create(createCommand(t, actor, id, i));
  }

  void rule(string policyId, string metric, string custom, string op, double threshold, int breach, int coolDown,
    string adjustment) {
    RuleInput i;
    i.policyId = policyId;
    i.metricType = metric;
    i.customMetricName = custom;
    i.operator = op;
    i.threshold = threshold;
    i.breachDurationSeconds = breach;
    i.coolDownSeconds = coolDown;
    i.adjustment = adjustment;
    ports.rules.create(createCommand(t, actor, "", i));
    r.rules++;
  }

  void schedule(ScheduleInput i) {
    ports.schedules.create(createCommand(t, actor, "", i));
    r.schedules++;
  }

  AppBinding binding(string id, string name, string guid, string policyId, int instances, string description) {
    BindingInput i;
    i.name = name;
    i.appGuid = guid;
    i.serviceInstanceId = "autoscaler-demo";
    i.policyId = policyId;
    i.currentInstances = instances;
    i.description = description;
    r.bindings++;
    return ports.bindings.create(createCommand(t, actor, id, i));
  }

  void load(string bindingId, string metric, double value, int seconds) {
    SimulateLoadRequest s;
    s.tenantId = t;
    s.actor = actor;
    s.bindingId = bindingId;
    s.metricName = metric;
    s.value = value;
    s.durationSeconds = seconds;
    s.stepSeconds = 30;
    r.samples += ports.metrics.simulate(s).length;
  }

  // ── policies ───────────────────────────────────────────────────────────
  policy("web-standard", "Web standard", "Interactive web applications: CPU and response time, business hours", 2, 10,
    "UTC", "sameApp");
  rule("web-standard", "cpu", "", ">=", 80, 120, 300, "+2");
  rule("web-standard", "cpu", "", "<", 20, 300, 600, "-1");
  rule("web-standard", "responsetime", "", ">", 500, 120, 300, "+1");
  ScheduleInput office;
  office.policyId = "web-standard";
  office.name = "Business hours";
  office.startTime = "08:00";
  office.endTime = "18:00";
  office.daysOfWeek = ["1", "2", "3", "4", "5"];
  office.instanceMinCount = 3;
  office.instanceMaxCount = 10;
  office.initialMinInstanceCount = 4;
  schedule(office);

  policy("batch-workers", "Batch workers", "Queue driven workers scaled on the custom metric 'jobqueue'", 1, 20, "UTC",
    "boundApp");
  rule("batch-workers", "custom", "jobqueue", ">", 100, 60, 120, "+50%");
  rule("batch-workers", "custom", "jobqueue", "<", 10, 300, 300, "-25%");
  ScheduleInput yearEnd;
  yearEnd.policyId = "batch-workers";
  yearEnd.name = "Year-end closing";
  yearEnd.kind = "specificDate";
  yearEnd.startDateTime = "2026-12-28T06:00";
  yearEnd.endDateTime = "2026-12-31T22:00";
  yearEnd.instanceMinCount = 5;
  yearEnd.instanceMaxCount = 20;
  yearEnd.initialMinInstanceCount = 8;
  schedule(yearEnd);

  auto reporting = policy("reporting", "Reporting (draft)", "Memory based scaling, not yet activated", 1, 4, "UTC", "sameApp");
  rule("reporting", "memoryutil", "", ">", 85, 180, 300, "+1");
  ports.policies.deactivate(t, reporting.id, actor);

  // ── bindings and load ──────────────────────────────────────────────────
  binding("shop-frontend", "shop-frontend", "a3f2c1d0-shop-frontend", "web-standard", 3, "Storefront UI");
  binding("order-service", "order-service", "7b91e4aa-order-service", "web-standard", 3, "Order API — currently under load");
  binding("invoice-worker", "invoice-worker", "c55d0b2e-invoice-worker", "batch-workers", 2, "Invoice batch worker");
  binding("reporting-ui", "reporting-ui", "e0a7f9c3-reporting-ui", "reporting", 1, "Policy still inactive");
  binding("legacy-admin", "legacy-admin", "19ce62f8-legacy-admin", "", 1, "Not autoscaled");

  load("shop-frontend", "cpu", 45, 600);
  load("shop-frontend", "responsetime", 180, 600);
  load("order-service", "cpu", 91, 300);
  load("order-service", "responsetime", 640, 300);
  load("invoice-worker", "jobqueue", 240, 180);
  load("reporting-ui", "memoryutil", 62, 300);
  return r;
}
