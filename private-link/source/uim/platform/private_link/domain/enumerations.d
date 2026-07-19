/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.enumerations;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
/// IaaS provider hosting the target service.
enum IaasProvider {
  azure,
  aws,
  gcp,
}

/// Lifecycle status of a private link service instance.
enum InstanceStatus {
  pending,
  provisioning,
  ready,
  failed,
  suspended,
  deleted_,
}

/// Approval/connection status of a private endpoint.
enum EndpointStatus {
  pendingAcceptance,
  approved,
  rejected,
  disconnected,
  ready,
  failed,
}

/// Status of an application service binding.
enum BindingStatus {
  creating,
  active,
  deleting,
  deleted_,
}

/// Service plan tier.
enum ServicePlan {
  standard,
  premium,
}

/// Network direction for endpoint exposure.
enum NetworkDirection {
  inbound,
  outbound,
}
