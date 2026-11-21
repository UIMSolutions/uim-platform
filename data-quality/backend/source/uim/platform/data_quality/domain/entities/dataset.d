/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A dataset is a named collection of data records (e.g. "customers",
/// "suppliers", a reference list of "countries"). It carries the latest
/// quality scorecard; the id is chosen by the client.
module uim.platform.data_quality.domain.entities.dataset;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct Dataset {
  mixin TenantEntity!DatasetId;

  string name;
  string description;
  string category; /// grouping label, e.g. "master data", "reference data"

  QualityScores scores; /// latest scorecard (valid if scoredAt > 0)
  long scoredAt;
  long validatedAt;
  long profiledAt;
  long duplicatesCheckedAt;

  bool isScored() const {
    return scoredAt > 0;
  }

  void validate() const {
    requireId(id.value, "Dataset ID");
    requireText(name, "Dataset name");
    requireMaxLength(name, 256, "Dataset name");
    requireMaxLength(description, 5000, "Description");
    requireMaxLength(category, 128, "Category");
  }
}

///
unittest {
  Dataset d;
  d.id = DatasetId("customers");
  d.name = "Customers";
  d.validate();
  assert(!d.isScored);
  d.id = DatasetId("a~b");
  assert(failsWith(DqErrorKind.invalid, () { d.validate(); }));
}
