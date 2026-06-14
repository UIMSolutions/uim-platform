/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.types;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:

struct RemoteTableId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataFlowId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ViewId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TaskId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TaskChainId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataAccessControlId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CatalogAssetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
