module uim.platform.service.interfaces.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IUIMTenant : ISAPEntity {
  bool isValid();

  bool validate();
}
