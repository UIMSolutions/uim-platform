/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A legal ground of a business purpose (e.g. "Contract" or "Commercial
/// law retention"). It belongs to exactly one business purpose and carries
/// at most one residence and one retention rule.
module uim.platform.data_retention.domain.entities.legal_ground;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct LegalGround {
  mixin TenantEntity!LegalGroundId;

  BusinessPurposeId businessPurposeId;
  string name;
  string description;
  LegalGroundType type = LegalGroundType.contract;
  string legalReference; /// e.g. "HGB §257, AO §147"
  bool active = true;

  void validate() const {
    requireId(id.value, "Legal ground ID");
    if (businessPurposeId.isNull)
      throw DataRetentionException.invalid("The business purpose of a legal ground is required");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(legalReference, 256, "Legal reference");
  }
}
