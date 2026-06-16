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
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DistributionModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct KeyMappingId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ChangeLogEntryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ClientId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ReplicationJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct FilterRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct VersionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}