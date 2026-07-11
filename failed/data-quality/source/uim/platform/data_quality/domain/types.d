/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.types;
import uim.platform.data_quality;
/// Unique identifier type aliases for type safety.
struct RecordId {
  mixin(IdTemplate);
}

struct ValidationRuleId {
  mixin(IdTemplate);
}

struct ValidationResultId {
  mixin(IdTemplate);
}

struct CleansingRuleId {
  mixin(IdTemplate);
}

struct DataProfileId {
  mixin(IdTemplate);
}

struct DatasetId {
  mixin(IdTemplate);
}

struct AddressId {
  mixin(IdTemplate);
}

struct MatchGroupId {
  mixin(IdTemplate);
}

struct CleansingJobId {
  mixin(IdTemplate);
}

struct ProfileJobId {
  mixin(IdTemplate);
}

struct QualityDashboardId {
  mixin(IdTemplate);
}


