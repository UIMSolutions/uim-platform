/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.types;

import uim.platform.hana;

// mixin(ShowModule!());

@safe:
// ID aliases
struct DatabaseInstanceId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct DataLakeId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct SchemaId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct DatabaseUserId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct BackupId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct AlertId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct HDIContainerId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ReplicationTaskId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ConfigurationId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct DatabaseConnectionId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}