module uim.platform.service.mixins.obj;

import uim.platform.service;

mixin(ShowModule!());

@safe:
string uimEntityTemplate() {
  return q{
    this() {
      super();
    }

    this(Json initData) {
      super(initData);
    }


    this(Json[string] initData) {
      super(initData);
    }
  };
}

template UIMEntityTemplate(alias Symbol) {
  const char[] UIMEntityTemplate = uimEntityTemplate();
}

string uimTenantEntityTemplate() {
  return q{
    this() {
      super();
    }

    this(UUID tenantId) {
      super();
      this.tenantId = tenantId;
    }

    this(Json initData) {
      super(initData);
    }

    this(Json[string] initData) {
      super(initData);
    }

    this(UUID tenantId, Json[string] initData) {
      super(initData);
      this.tenantId = tenantId;
    }
  };
}

template UIMTenantEntityTemplate(alias Symbol) {
  const char[] UIMTenantEntityTemplate = uimTenantEntityTemplate();
}