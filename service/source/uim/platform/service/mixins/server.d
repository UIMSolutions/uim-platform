module uim.platform.service.mixins.server;
import uim.platform.service;

mixin(ShowModule!());

@safe:
string sapServerTemplate() {
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

template UIMServerTemplate(alias Symbol) {
  const char[] SAPServerTemplate = sapServerTemplate();
}
