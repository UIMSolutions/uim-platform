module uim.platform.service.domain.types;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct GlobalAccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ConnectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct OrganizationId {
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

struct OrgId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}