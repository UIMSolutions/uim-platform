/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Runtime environment kind of a registered platform.
enum PlatformType : string {
  cloudFoundry = "cloudFoundry",
  kubernetes = "kubernetes",
  kyma = "kyma",
  neo = "neo",
  other = "other"
}

/// Availability of a registered platform. Only active platforms accept new instances.
enum PlatformStatus : string {
  active = "active",
  inactive = "inactive",
  suspended = "suspended"
}
