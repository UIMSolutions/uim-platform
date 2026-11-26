/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the application bindings.
module uim.platform.application_autoscaler.ports.usecases.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManageBindings : IManageResource!(AppBinding, AppBindingId, BindingInput) {
  /// Attach a policy (replaces an attached one).
  AppBinding attachPolicy(TenantId t, AppBindingId id, ScalingPolicyId policy, UserId actor);
  /// Detach the policy: autoscaling stops, the instances stay.
  AppBinding detachPolicy(TenantId t, AppBindingId id, UserId actor);
  /// Pause autoscaling (manual scaling stays possible).
  AppBinding suspend(TenantId t, AppBindingId id, UserId actor);
  AppBinding resume(TenantId t, AppBindingId id, UserId actor);
}
