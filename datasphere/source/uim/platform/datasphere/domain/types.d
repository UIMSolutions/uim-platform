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

  mixin DomainId;
}

struct DataFlowId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ViewId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TaskId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TaskChainId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DataAccessControlId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CatalogAssetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
