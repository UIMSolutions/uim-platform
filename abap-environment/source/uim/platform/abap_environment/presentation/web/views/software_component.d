/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.software_component;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.software_component;

mixin(ShowModule!());
@safe:

class SoftwareComponentHtmlView {
  string renderList(SoftwareComponentViewModel[] models) {
    return string.init;
  }

  string renderDetail(SoftwareComponentViewModel model) {
    return string.init;
  }

  string renderForm(SoftwareComponentViewModel model = SoftwareComponentViewModel.init) {
    return string.init;
  }
}
