/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.types;
import uim.platform.data_quality;
/// Unique identifier type aliases for type safety.
struct RecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ValidationRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ValidationResultId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CleansingRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataProfileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DatasetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AddressId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct MatchGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CleansingJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProfileJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct QualityDashboardId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}


