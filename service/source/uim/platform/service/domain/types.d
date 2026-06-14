module uim.platform.service.domain.types;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct GlobalAccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ConnectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct OrganizationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SpaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct OrgId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}