/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.system_instance;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.system_instance;

// mixin(ShowModule!());
@safe:

class SystemInstanceHtmlView {
  string renderList(SystemInstanceViewModel[] models) {
    return string.init;
  }

  string renderDetail(SystemInstanceViewModel model) {
    return string.init;
  }

  string renderForm(SystemInstanceViewModel model = SystemInstanceViewModel.init) {
    return string.init;
  }
}
