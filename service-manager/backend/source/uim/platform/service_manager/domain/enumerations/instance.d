/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Lifecycle state of a service instance (see domain.services.lifecycle).
enum ServiceInstanceStatus : string {
  creating = "creating",
  created = "created",
  updating = "updating",
  deleting = "deleting",
  failed = "failed",
  orphaned = "orphaned"
}
