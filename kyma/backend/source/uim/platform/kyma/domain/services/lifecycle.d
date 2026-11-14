/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.lifecycle;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Reconciliation semantics: every transitional state moves one step towards
/// its target state. Each function returns true if the entity changed.
/// (Pure domain rules — the reconcile use case decides when they apply.)

bool advance(ref KymaEnvironment e) {
  switch (e.status) {
  case EnvironmentStatus.provisioning, EnvironmentStatus.updating:
    e.status = EnvironmentStatus.running;
    return true;
  case EnvironmentStatus.stopping:
    e.status = EnvironmentStatus.stopped;
    return true;
  default:
    return false;
  }
}

bool advance(ref ServerlessFunction f) {
  switch (f.status) {
  case FunctionStatus.building:
    f.status = FunctionStatus.deploying;
    return true;
  case FunctionStatus.deploying:
    f.status = FunctionStatus.running;
    return true;
  default:
    return false;
  }
}

bool advance(ref ApiRule r) {
  if (r.status != ApiRuleStatus.notReady)
    return false;
  r.status = ApiRuleStatus.ok;
  return true;
}

bool advance(ref ServiceInstance s) {
  if (s.status != ServiceInstanceStatus.creating && s.status != ServiceInstanceStatus.updating)
    return false;
  s.status = ServiceInstanceStatus.ready;
  return true;
}

/// A binding becomes ready once its instance is ready; the secret then holds the credential keys.
bool advance(ref ServiceBinding b, ServiceInstanceStatus instanceStatus) {
  if (b.status != ServiceBindingStatus.creating || instanceStatus != ServiceInstanceStatus.ready)
    return false;
  b.status = ServiceBindingStatus.ready;
  b.credentialKeys = ["clientid", "clientsecret", "url", "uaa"];
  return true;
}

bool advance(ref EventSubscription s) {
  if (s.status != SubscriptionStatus.pending)
    return false;
  s.status = SubscriptionStatus.active;
  return true;
}

bool advance(ref KymaModule m) {
  switch (m.status) {
  case ModuleStatus.installing:
    m.status = ModuleStatus.enabled;
    return true;
  case ModuleStatus.uninstalling:
    m.status = ModuleStatus.disabled;
    return true;
  default:
    return false;
  }
}

bool advance(ref KymaApplication a) {
  if (a.status != AppConnectivityStatus.pairing)
    return false;
  a.status = AppConnectivityStatus.connected;
  return true;
}

///
unittest {
  ServerlessFunction f;
  assert(advance(f) && f.status == FunctionStatus.deploying);
  assert(advance(f) && f.status == FunctionStatus.running);
  assert(!advance(f));

  ServiceBinding b;
  assert(!advance(b, ServiceInstanceStatus.creating));
  assert(advance(b, ServiceInstanceStatus.ready) && b.credentialKeys.length == 4);
}
