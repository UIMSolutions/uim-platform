/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

/// Unique identifier type aliases for type safety.
struct RecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProfileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DatasetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AddressId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct MatchGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CleansingJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProfileJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

// struct TenantId {
//   string value;

//   this(string value) {
//     this.value = value;
//   }

//   mixin DomainId;
// }

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
