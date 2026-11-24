/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of cheap reference counts for list views ("3 business
/// purposes, 12 data subjects") — without evaluating every data subject.
module uim.platform.data_retention.ports.services.lookups;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IDrLookups {
  /// Data subjects per value of a reference attribute (applicationGroupId,
  /// businessPurposeId, legalGroundId, dataSubjectRoleId, legalEntityId).
  long[string] dataSubjectCounts(TenantId t, string attribute);
  /// Business purposes per value of applicationGroupId, dataSubjectRoleId or legalEntityId.
  long[string] businessPurposeCounts(TenantId t, string attribute);
}
