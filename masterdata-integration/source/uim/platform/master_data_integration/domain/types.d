/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.types;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct MasterDataObjectId {
  mixin(IdTemplate);
}

struct DataModelId {
  mixin(IdTemplate);
}

struct DistributionModelId {
  mixin(IdTemplate);
}

struct KeyMappingId {
  mixin(IdTemplate);
}

struct ChangeLogEntryId {
  mixin(IdTemplate);
}

struct ClientId {
  mixin(IdTemplate);
}

struct ReplicationJobId {
  mixin(IdTemplate);
}

struct FilterRuleId {
  mixin(IdTemplate);
}

struct VersionId {
  mixin(IdTemplate);
}