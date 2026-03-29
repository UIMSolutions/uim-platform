module uim.platform.service.mixins.config;
import uim.platform.service;

mixin(ShowModule!());

@safe:
string uimConfigTemplate() {
  return "
  this() {
    super();
  }

  this(Json[string] initData) {
    super(initData);
  }
  ";
}

template UIMConfigTemplate(alias Symbol) {
  const char[] UIMConfigTemplate = uimConfigTemplate();
}