/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.types;

import uim.platform.foundry;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
// struct OrgId {
//   string value;

//   this(string value) {
//     this.value = value;
//   }

//   mixin DomainId;
// }

// struct SpaceId {
//   string value;

//   this(string value) {
//     this.value = value;
//   }

//   mixin DomainId;
// }

struct AppId {
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

struct ServiceBindingId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RouteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CfDomainId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BuildpackId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
