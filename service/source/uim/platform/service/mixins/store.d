module uim.platform.service.mixins.store;
import uim.platform.service;

mixin(ShowModule!());

@safe:
string sapStoreTemplate() {
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

template UIMStoreTemplate(alias Symbol) {
  const char[] SAPStoreTemplate = sapStoreTemplate();
}
