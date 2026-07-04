/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.types;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

// --- Domain ID types ---

struct DataProviderId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct DataProductId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct UnificationRuleId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct DataSourceConfigId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct AttributeMappingId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct CustomerProfileId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct CompositionRunId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct TenantUserId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

// --- Value types ---

/// A single field definition in a data schema
struct AttributeSchema {
  string name;
  string dataType;
  bool required;
  string description;
}

/// Timestamp ingestion configuration for a source data product
struct TimestampConfig {
  string format;     /// TimestampFormat value
  string fieldName;  /// Source field to use as timestamp
  string customPattern; /// Used when format == custom
}

/// Maps a source attribute to a unification rule identifier attribute
struct IdentifierMapping {
  string ruleId;
  string ruleAttributeName;
  string sourceAttributeName;
  string transformationType;
}

/// A single attribute transformation applied in a mapping
struct MappingTransformation {
  string type;       /// TransformationType value
  string parameter;  /// Optional parameter (e.g., delimiter for append)
}
