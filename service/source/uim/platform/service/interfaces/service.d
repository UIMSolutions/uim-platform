module uim.platform.service.interfaces.service;
import uim.platform.service;

mixin(ShowModule!());

@safe:
interface IUIMService {
  ISAPConfig config();
  void config(ISAPConfig cfg);

  Json health();
  Json ready();
}
