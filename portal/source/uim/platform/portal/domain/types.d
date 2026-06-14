/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.types;

import uim.platform.portal;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SiteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PageId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CatalogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct GroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct RoleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ProviderId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ThemeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct MenuItemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TranslationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}