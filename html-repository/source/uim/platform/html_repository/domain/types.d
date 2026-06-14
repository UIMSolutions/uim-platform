/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.types;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:
// ID aliases
struct HtmlAppId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AppVersionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AppFileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DeploymentRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AppRouteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ContentCacheId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}


// struct SpaceId {
//   string value;

//   this(string value) {
//     this.value = value;
//   }

//   mixin IdTemplate;
// }