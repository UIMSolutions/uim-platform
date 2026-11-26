/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Metric ingestion: standard metrics from the platform's collector,
/// custom metrics from the applications.
///
/// Rules: the binding is addressed by id or application GUID; standard
/// metric names are lower case; values are >= 0 and not in the future;
/// custom metrics from another application are accepted only if the
/// policy allows "boundApp" and the sender is bound to the same service
/// instance. Samples and scaling events are purged after their retention.
module uim.platform.application_autoscaler.application.usecases.metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ManageMetricsUseCase : AasInteractor, IManageMetrics {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  MetricSample submit(SubmitMetricRequest r) {
    auto b = resolveBinding(r.tenantId, r.bindingId, r.appGuid);
    auto name = canonicalMetricName(r.metricName);
    MetricSample m;
    stampCreated!(MetricSample, MetricSampleId)(m, r.tenantId, r.actor, newResourceId(), nextTime);
    m.bindingId = b.id;
    m.metricName = name;
    m.value = r.value;
    m.source = r.source.strip.length ? r.source.strip : "api";
    m.measuredAt = r.measuredAt.strip.length ? parseIsoTime(r.measuredAt, "Measurement time") : now;
    if (m.measuredAt > plusSeconds(now, 60))
      throw AasException.invalid("The measurement time must not be in the future");
    if (m.isCustom)
      requireCustomMetricSender(r.tenantId, b, r.senderAppGuid.strip);
    m.unit = r.unit.strip.length ? r.unit.strip : m.isCustom ? "" : metricUnit(parseDomainEnum!MetricType(name));
    m.validate();
    repos.metrics.save(m);
    return m;
  }

  MetricSample[] simulate(SimulateLoadRequest r) {
    auto b = bindingOf(r.tenantId, AppBindingId(r.bindingId.strip));
    auto name = canonicalMetricName(r.metricName);
    requireRange(r.durationSeconds, 0, 3600, "Duration (seconds)");
    requireRange(r.stepSeconds, 5, 600, "Step (seconds)");
    auto count = r.durationSeconds / r.stepSeconds + 1;
    if (count > policy.maxSimulationSamples)
      throw AasException.invalid(format("The simulation would create %d samples (maximum %d)", count,
          policy.maxSimulationSamples));
    MetricSample[] created;
    auto at = now;
    batch(() {
      foreach_reverse (k; 0 .. count) {
        MetricSample m;
        stampCreated!(MetricSample, MetricSampleId)(m, r.tenantId, r.actor, newResourceId(), nextTime);
        m.bindingId = b.id;
        m.metricName = name;
        m.value = r.value;
        m.source = "simulator";
        m.measuredAt = plusSeconds(at, -cast(long) k * r.stepSeconds);
        m.unit = m.isCustom ? "" : metricUnit(parseDomainEnum!MetricType(name));
        m.validate();
        repos.metrics.save(m);
        created ~= m;
      }
    });
    emit("metrics.simulated", r.tenantId, b.id.value, Json(["metric": Json(name), "value": Json(r.value),
        "samples": Json(created.length)]));
    return created;
  }

  MetricSample get(TenantId t, MetricSampleId id) {
    return required(repos.metrics.findById(t, id), "Metric sample '" ~ id.value ~ "'");
  }

  MetricSample[] list(TenantId t) {
    return repos.metrics.findAll(t);
  }

  MetricSample[] listOf(TenantId t, AppBindingId binding) {
    bindingOf(t, binding);
    return repos.metrics.findByReference(t, "bindingId", binding.value);
  }

  void remove(TenantId t, MetricSampleId id, UserId actor) {
    get(t, id);
    repos.metrics.removeById(t, id);
  }

  PurgeResult purge(TenantId t, UserId actor) {
    PurgeResult r;
    batch(() {
      r.samples = repos.metrics.removeOlderThan(t, plusSeconds(now, -policy.metricRetentionHours * 3600));
      r.events = repos.events.removeOlderThan(t, plusDays(now, -policy.eventRetentionDays));
    });
    if (r.samples + r.events > 0)
      emit("metrics.purged", t, t.value, Json(["samples": Json(r.samples), "events": Json(r.events)]));
    return r;
  }

  // ── helpers ────────────────────────────────────────────────────────────
  protected AppBinding resolveBinding(TenantId t, string bindingId, string appGuid) {
    if (bindingId.strip.length)
      return bindingOf(t, AppBindingId(bindingId.strip));
    if (appGuid.strip.length == 0)
      throw AasException.invalid("A binding or an application GUID is required");
    auto found = repos.bindings.findByReference(t, "appGuid", appGuid.strip);
    if (found.length == 0)
      throw AasException.notFound("Binding of application '" ~ appGuid.strip ~ "'");
    return found[0];
  }

  /// "CPU" → "cpu" for standard metrics; custom names as given.
  protected static string canonicalMetricName(string text) {
    auto n = text.strip;
    if (domainEnumValues!MetricType.canFind(n.toLower)) {
      if (n.toLower == cast(string) MetricType.custom)
        throw AasException.invalid("'custom' is not a metric name; send the custom metric's own name");
      return n.toLower;
    }
    if (!isValidMetricName(n))
      throw AasException.invalid("Metric name '" ~ text ~ "' is invalid (1-100 characters: letters, digits, '_', '-', '.')");
    return n;
  }

  protected void requireCustomMetricSender(TenantId t, const AppBinding b, string sender) {
    if (sender.length == 0 || sender == b.appGuid)
      return;
    auto allow = MetricAllowFrom.sameApp;
    if (b.hasPolicy) {
      auto p = repos.policies.findById(t, b.policyId);
      if (!p.isNull)
        allow = p.customMetricAllowFrom;
    }
    if (allow == MetricAllowFrom.sameApp)
      throw AasException.ruleViolation("Custom metrics of '" ~ b.name ~ "' may only be sent by the application itself");
    foreach (other; repos.bindings.findByReference(t, "appGuid", sender))
      if (other.serviceInstanceId == b.serviceInstanceId && b.serviceInstanceId.length)
        return;
    throw AasException.ruleViolation("Application '" ~ sender ~ "' is not bound to the service instance of '" ~ b.name ~ "'");
  }
}
