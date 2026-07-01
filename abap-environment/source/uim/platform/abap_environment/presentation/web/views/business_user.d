/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.business_user;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.business_user;

// mixin(ShowModule!());
@safe:

class BusinessUserHtmlView {
  string renderList(BusinessUserViewModel[] models) {
    return string.init;
  }

  string renderDetail(BusinessUserViewModel model) {
    return string.init;
  }

  string renderForm(BusinessUserViewModel model = BusinessUserViewModel.init) {
    return string.init;
  }
}
