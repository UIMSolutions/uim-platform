module uim.platform.service.domain.types;

import uim.platform.service;

mixin(ShowModule!());

@safe:

// alias TenantId = string;

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}