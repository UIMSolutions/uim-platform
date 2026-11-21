/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// One record of a dataset: an ordered list of field values plus the
/// result of its latest validation.
module uim.platform.data_quality.domain.entities.data_record;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum size_t maxFieldsPerRecord = 500;

struct DataRecord {
  mixin TenantEntity!RecordId;

  DatasetId datasetId;
  FieldValue[] fields;

  // latest validation
  double qualityScore = 100; /// passed rules / checked rules (%)
  int rulesChecked;
  int violationCount;
  string worstSeverity; /// "" = no violation
  long validatedAt;

  string field(string name) const {
    return fieldOf(fields, name);
  }

  bool isValidated() const {
    return validatedAt > 0;
  }

  /// Forget the validation result (fields changed).
  void resetValidation() {
    qualityScore = 100;
    rulesChecked = 0;
    violationCount = 0;
    worstSeverity = "";
    validatedAt = 0;
  }

  void validate() const {
    requireId(id.value, "Record ID");
    if (datasetId.isNull)
      throw DataQualityException.invalid("Dataset is required");
    if (fields.length > maxFieldsPerRecord)
      throw DataQualityException.invalid(format("A record must not have more than %d fields", maxFieldsPerRecord));
    checkedFields(fields);
  }
}

///
unittest {
  DataRecord r;
  r.id = RecordId("c1");
  r.datasetId = DatasetId("customers");
  r.fields = [FieldValue("name", "Ada")];
  r.validate();
  assert(r.field("name") == "Ada" && !r.isValidated);
  r.fields ~= FieldValue("bad name", "");
  assert(failsWith(DqErrorKind.invalid, () { r.validate(); }));
}
