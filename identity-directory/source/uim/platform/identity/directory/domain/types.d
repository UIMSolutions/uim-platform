/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.types;
/// Unique identifier type aliases for type safety.
import uim.platform.identity.directory;

// mixin(ShowModule!());

@safe:

struct IAMGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SchemaId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AttributeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ApiClientId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}