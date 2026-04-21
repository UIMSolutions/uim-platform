/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.distribution_model;

import uim.platform.master_data_integration.domain.types;

/// A distribution model defines which data flows from/to which clients.
struct DistributionModel {
  mixin TenantEntity!(DistributionModelId);
  
  string name;
  string description;
  DistributionModelStatus status = DistributionModelStatus.draft;
  DistributionDirection direction = DistributionDirection.outbound;

  // Source & target
  ClientId sourceClientId;
  ClientId[] targetClientIds;

  // Data scope
  MasterDataCategory[] categories;
  DataModelId[] dataModelIds;

  // Filter rules applied to this distribution
  FilterRuleId[] filterRuleIds;

  // Scheduling
  bool autoReplicate;
  string cronSchedule; // e.g. "0 */6 * * *"

  Json toJson() const {
    return Json.entityToJson
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("direction", direction.to!string)
      .set("sourceClientId", sourceClientId)
      .set("targetClientIds", targetClientIds.array)
      .set("categories", categories.map!(c => c.to!string).array)
      .set("dataModelIds", dataModelIds.array)
      .set("filterRuleIds", filterRuleIds.array)
      .set("autoReplicate", autoReplicate)
      .set("cronSchedule", cronSchedule);
  }
}
