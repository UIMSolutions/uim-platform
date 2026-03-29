module uim.platform.service.interfaces.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IUIMTenant : IUIMEntity {
  bool isValid();

  bool validate();
}
