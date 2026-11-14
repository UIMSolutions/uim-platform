/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Lifecycle state of a service binding (see domain.services.lifecycle).
enum ServiceBindingStatus : string {
  creating = "creating",
  created = "created",
  deleting = "deleting",
  failed = "failed"
}
