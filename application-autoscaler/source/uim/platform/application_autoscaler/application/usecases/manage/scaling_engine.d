/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.scaling_engine;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:
/// Orchestrates the autoscaling decision: evaluate policy rules against
/// the submitted metric and record a scaling history event.
class ScalingEngineUseCase {
  private ScalingPolicyRepository  policyRepo;
  private AppBindingRepository     bindingRepo;
  private ScalingHistoryRepository historyRepo;
  private ScalingEvaluatorService  evaluator;

  this(
    ScalingPolicyRepository  policyRepo,
    AppBindingRepository     bindingRepo,
    ScalingHistoryRepository historyRepo,
    ScalingEvaluatorService  evaluator
  ) {
    this.policyRepo  = policyRepo;
    this.bindingRepo = bindingRepo;
    this.historyRepo = historyRepo;
    this.evaluator   = evaluator;
  }

  CommandResult triggerScaling(TriggerScalingRequest r) {
    import core.time : MonoTime;
    
    import std.random : uniform;

    // Resolve binding
    auto binding = bindingRepo.findByAppGuid(r.tenantId, r.appId);
    if (binding.isNull)
      return CommandResult(false, "", "No binding found for appId " ~ r.appId);

    if (binding.policyId.length == 0)
      return CommandResult(false, "", "No policy attached to app binding");

    auto policy = policyRepo.findById(binding.policyId);
    if (policy.isNull)
      return CommandResult(false, "", "Policy not found");

    if (policy.status != PolicyStatus.active)
      return CommandResult(false, "", "Policy is not active");

    int currentInstances = binding.currentInstances > 0 ? binding.currentInstances : 1;
    int newInstances = evaluator.evaluate(policy, r.metricType, r.currentValue, currentInstances);

    ScalingDirection direction = ScalingDirection.none;
    if (newInstances > currentInstances)      direction = ScalingDirection.scaleOut;
    else if (newInstances < currentInstances) direction = ScalingDirection.scaleIn;

    auto histId = "hist-" ~ currentTimestamp.to!string ~ "-" ~ uniform(1000, 9999).to!string;

    ScalingHistoryEntity evt;
    evt.id           = histId;
    evt.appId        = binding.id;
    evt.tenantId     = binding.tenantId;
    evt.direction    = direction;
    evt.status       = ScalingStatus.succeeded;
    evt.reason       = "Metric " ~ r.metricType ~ " = " ~ r.currentValue.to!string;
    evt.oldInstances = currentInstances;
    evt.newInstances = newInstances;
    evt.timestamp    = currentTimestamp;

    if (direction != ScalingDirection.none) {
      // Update binding instance count
      binding.currentInstances = newInstances;
      binding.updatedAt        = currentTimestamp;
      bindingRepo.update(binding);
    } else {
      evt.status  = ScalingStatus.ignored;
      evt.message = "No rule breached";
    }

    historyRepo.save(evt);
    return CommandResult(true, histId, "");
  }
}
