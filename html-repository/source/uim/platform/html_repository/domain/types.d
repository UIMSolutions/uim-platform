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

  mixin DomainId;
}

struct AppVersionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppFileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DeploymentRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppRouteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentCacheId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}


struct SpaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}