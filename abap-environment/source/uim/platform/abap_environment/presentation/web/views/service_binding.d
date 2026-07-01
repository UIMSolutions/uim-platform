/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.service_binding;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.service_binding;

// mixin(ShowModule!());
@safe:

class ServiceBindingHtmlView {
  string renderList(ServiceBindingViewModel[] models) {
    return string.init;
  }

  string renderDetail(ServiceBindingViewModel model) {
    return string.init;
  }

  string renderForm(ServiceBindingViewModel model = ServiceBindingViewModel.init) {
    return string.init;
  }
}
