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

  string toString() const {
    return value;
  }

  bool isEmpty() const {
    return value.length == 0;
  }

  bool isNull() const {
    return value.length == 0;
  }
}