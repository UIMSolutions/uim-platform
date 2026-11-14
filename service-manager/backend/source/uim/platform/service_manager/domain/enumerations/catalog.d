/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.catalog;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Catalog state of a service offering.
enum ServiceOfferingStatus : string {
  available = "available",
  deprecated_ = "deprecated", /// visible, no new instances
  removed = "removed" /// no longer advertised by the broker
}

/// Business category of a service offering.
enum ServiceCategory : string {
  platform = "platform",
  application = "application",
  integration = "integration",
  data = "data",
  security = "security",
  ai = "ai",
  other = "other"
}

/// Pricing model of a service plan.
enum ServicePlanPricing : string {
  free = "free",
  paid = "paid",
  beta = "beta"
}
