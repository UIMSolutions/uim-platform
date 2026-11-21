/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A cleansed postal address: the raw input and the standardized output
/// (country as ISO 3166 alpha-2, title cased city/region, expanded street
/// abbreviations, normalized postal code) with the quality assessment.
module uim.platform.data_quality.domain.entities.address;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct PostalAddress {
  mixin TenantEntity!AddressId;

  string sourceRecordId; /// optional link to a record ("<datasetId>~<recordId>" or any reference)
  AddressInput input;
  AddressOutcome output;
  long cleansedAt;
}
