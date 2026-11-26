/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The scaling engine: evaluates the policy of a binding (rules, schedules,
/// limits — see domain.services.scaling_decider), asks the platform to
/// change the instances and records the decision in the scaling history.
/// Also manual scaling and the history queries.
module uim.platform.application_autoscaler.application.usecases.scaling;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ScalingEngineUseCase : AasInteractor, IScalingEngine {
  protected IInstanceController controller;

  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy,
    IInstanceController controller) {
    super(repos, clock, events, unitOfWork, policy);
    this.controller = controller;
  }

  ScalingDecision preview(TenantId t, AppBindingId id) {
    auto b = bindingOf(t, id);
    if (!b.hasPolicy)
      throw AasException.ruleViolation("Binding '" ~ b.name ~ "' has no policy");
    return decide(t, b, policyOf(t, b.policyId));
  }

  EvaluationResult evaluate(TenantId t, AppBindingId id, UserId actor) {
    auto b = bindingOf(t, id);
    string skip;
    ScalingPolicy p;
    if (b.status == BindingStatus.suspended)
      skip = "autoscaling is suspended";
    else if (!b.hasPolicy)
      skip = "no policy attached";
    else {
      p = repos.policies.findById(t, b.policyId);
      if (p.isNull)
        skip = "policy '" ~ b.policyId.value ~ "' not found";
      else if (!p.isActive)
        skip = "policy '" ~ p.name ~ "' is inactive";
    }
    if (skip.length) {
      auto r = baseResult(b);
      r.reason = skip;
      b.lastEvaluatedAt = now;
      b.lastDecision = skip;
      repos.bindings.save(b);
      return r;
    }
    auto d = decide(t, b, p);
    return apply(t, b, p, d, actor);
  }

  EvaluationSummary evaluateAll(TenantId t, UserId actor) {
    EvaluationSummary s;
    batch(() {
      bool[string] active;
      foreach (p; repos.policies.findAll(t))
        active[p.id.value] = p.isActive;
      foreach (b; repos.bindings.findAll(t)) {
        s.bindings++;
        if (!b.isAutoscaled || !active.get(b.policyId.value, false)) {
          s.skipped++;
          continue;
        }
        try
          s.add(evaluate(t, b.id, actor));
        catch (AutoscalerException e) {
          s.failed++;
          s.messages ~= b.name ~ ": " ~ e.msg;
        }
      }
    });
    return s;
  }

  EvaluationResult scaleManually(TenantId t, AppBindingId id, int instances, string reason, UserId actor) {
    auto b = bindingOf(t, id);
    auto max = maxInstancesLimit;
    ScalingPolicy p;
    if (b.hasPolicy) {
      p = repos.policies.findById(t, b.policyId);
      if (!p.isNull)
        max = p.instanceMaxCount;
    }
    requireRange(instances, 1, max, "Instances");
    ScalingDecision d;
    d.trigger = ScalingTrigger.manual;
    d.current = b.currentInstances;
    d.target = instances;
    d.direction = instances > d.current ? ScalingDirection.scaleOut : instances < d.current ? ScalingDirection.scaleIn
      : ScalingDirection.none;
    d.reason = "manual: " ~ (reason.strip.length ? reason.strip : "set by " ~ actor.value);
    d.limits.min = 1;
    d.limits.max = max;
    d.limits.source = p.isNull ? "global limit" : "policy";
    if (!d.changes)
      throw AasException.ruleViolation(format("'%s' already runs %d instances", b.name, instances));
    return apply(t, b, p, d, actor);
  }

  ScalingEvent getEvent(TenantId t, ScalingEventId id) {
    return required(repos.events.findById(t, id), "Scaling event '" ~ id.value ~ "'");
  }

  ScalingEvent[] listEvents(TenantId t) {
    return repos.events.findAll(t);
  }

  // ── internals ──────────────────────────────────────────────────────────
  protected ScalingDecision decide(TenantId t, const AppBinding b, const ScalingPolicy p) {
    auto rules = repos.rules.findByReference(t, "policyId", p.id.value);
    auto schedules = repos.schedules.findByReference(t, "policyId", p.id.value);
    auto samples = repos.metrics.findByReference(t, "bindingId", b.id.value);
    return decideScaling(b, p, rules, schedules, samples, now, policy.metricStaleSeconds);
  }

  protected EvaluationResult baseResult(const AppBinding b) {
    EvaluationResult r;
    r.bindingId = b.id;
    r.bindingName = b.name;
    r.oldInstances = b.currentInstances;
    r.newInstances = b.currentInstances;
    return r;
  }

  protected EvaluationResult apply(TenantId t, AppBinding b, const ScalingPolicy p, const ScalingDecision d, UserId actor) {
    auto r = baseResult(b);
    r.trigger = d.trigger;
    r.reason = d.reason;
    r.minInstances = d.limits.min;
    r.maxInstances = d.limits.max;
    r.limitSource = d.limits.source;
    auto at = now;
    if (d.changes) {
      ScaleRequest request;
      request.tenantId = t;
      request.bindingId = b.id;
      request.appGuid = b.appGuid;
      request.appName = b.name;
      request.currentInstances = d.current;
      request.targetInstances = d.target;
      request.reason = d.reason;
      auto outcome = controller.scale(request);
      r.message = outcome.message;
      if (outcome.success) {
        r.status = ScalingStatus.succeeded;
        r.direction = d.direction;
        r.newInstances = outcome.instances > 0 ? outcome.instances : d.target;
        b.currentInstances = r.newInstances;
        b.lastScaledAt = at;
      } else {
        r.status = ScalingStatus.failed;
        r.direction = d.direction;
      }
    }
    if (r.status != ScalingStatus.ignored || policy.recordIgnored) {
      ScalingEvent e;
      stampCreated!(ScalingEvent, ScalingEventId)(e, t, actor, newResourceId(), nextTime);
      e.bindingId = b.id;
      e.policyId = p.isNull ? ScalingPolicyId.init : p.id;
      e.ruleId = d.ruleId;
      e.scheduleId = d.scheduleId;
      e.trigger = d.trigger;
      e.direction = r.direction;
      e.status = r.status;
      e.oldInstances = r.oldInstances;
      e.newInstances = r.status == ScalingStatus.failed ? d.target : r.newInstances;
      e.metricName = d.metricName;
      e.metricValue = d.metricValue;
      e.threshold = d.threshold;
      e.reason = d.reason;
      e.message = r.message;
      repos.events.save(e);
      r.eventId = e.id;
    }
    b.lastEvaluatedAt = at;
    b.lastDecision = r.status == ScalingStatus.ignored ? d.reason : format("%s %d → %d: %s", cast(string) r.status,
      r.oldInstances, r.status == ScalingStatus.failed ? d.target : r.newInstances, d.reason);
    if (b.lastDecision.length > 500)
      b.lastDecision = b.lastDecision[0 .. 497] ~ "...";
    repos.bindings.save(b);
    if (r.status != ScalingStatus.ignored)
      emit("scaling." ~ cast(string) r.status, t, b.id.value, Json([
          "trigger": Json(cast(string) d.trigger), "from": Json(r.oldInstances), "to": Json(d.target),
          "reason": Json(d.reason)
        ]));
    return r;
  }
}
