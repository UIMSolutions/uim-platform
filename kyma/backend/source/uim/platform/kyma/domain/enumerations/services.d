/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.services;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Status of a BTP service instance (BTP service operator).
enum ServiceInstanceStatus {
  creating,
  ready,
  updating,
  failed,
}

/// Status of a service binding.
enum ServiceBindingStatus {
  creating,
  ready,
  failed,
}

///
unittest {
  assert(parseEnum!ServiceInstanceStatus("READY", ServiceInstanceStatus.failed) == ServiceInstanceStatus.ready);
}
