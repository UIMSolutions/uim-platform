module uim.apps.tests.app;

mixin(Version!("test_uim_apps"));

import uim.apps;
@safe:

bool testApp(IApp app) {
  assert(app !is null);

  return true;
}
