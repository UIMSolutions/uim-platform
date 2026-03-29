module uim.platform.service.interfaces.service;
import uim.platform.service;

mixin(ShowModule!());

@safe:
interface IUIMService {
  IUIMConfig config();
  void config(IUIMConfig cfg);

  Json health();
  Json ready();
}
