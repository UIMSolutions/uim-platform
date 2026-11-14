/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.service_offering;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// A service advertised by a broker.
struct ServiceOffering {
  mixin TenantEntity!ServiceOfferingId;

  ServiceBrokerId brokerId;
  string name;
  string description;
  string catalogId; /// broker side id (OSB service id)
  string catalogName; /// broker side name
  ServiceOfferingStatus status = ServiceOfferingStatus.available;
  ServiceCategory category = ServiceCategory.other;
  bool bindable = true;
  bool instancesRetrievable;
  bool bindingsRetrievable;
  bool planUpdateable = true;
  string metadata; /// JSON text
  string[] tags;

  bool isAvailable() const {
    return status == ServiceOfferingStatus.available;
  }

  void validate() const {
    requireName(name, "Service offering");
    if (brokerId.isNull)
      throw ServiceManagerException.invalid("Service offering brokerId is required");
    requireJsonText(metadata, "metadata");
  }
}
