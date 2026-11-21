/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.data_quality.domain.types.ids;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct DatasetId { mixin(IdTemplate); }
struct RecordId { mixin(IdTemplate); }
struct ValidationRuleId { mixin(IdTemplate); }
struct ViolationId { mixin(IdTemplate); }
struct CleansingRuleId { mixin(IdTemplate); }
struct CleansingJobId { mixin(IdTemplate); }
struct MatchGroupId { mixin(IdTemplate); }
struct ColumnProfileId { mixin(IdTemplate); }
struct AddressId { mixin(IdTemplate); }
struct SnapshotId { mixin(IdTemplate); }

/// A new identifier for server generated resources: 16 lowercase hex
/// characters (short enough for URLs, logs and composite keys).
string newResourceId() @trusted {
  import std.uuid : randomUUID;
  import std.array : replace;

  return randomUUID().toString.replace("-", "")[0 .. 16];
}

///
unittest {
  auto a = newResourceId();
  assert(a.length == 16 && a != newResourceId());
  assert(DatasetId("customers").value == "customers" && DatasetId.init.isNull);
}
