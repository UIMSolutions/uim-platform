module uim.platform.service.mixins.service;
import uim.platform.service;

mixin(ShowModule!());

@safe:
string sapServiceTemplate() {
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

template UIMServiceTemplate(alias Symbol) {
  const char[] SAPServiceTemplate = sapServiceTemplate();
}