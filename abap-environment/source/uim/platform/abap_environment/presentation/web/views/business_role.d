/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.business_role;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.business_role;

mixin(ShowModule!());
@safe:

class BusinessRoleHtmlView {
  string renderList(BusinessRoleViewModel[] models) {
    return string.init;
  }

  string renderDetail(BusinessRoleViewModel model) {
    return string.init;
  }

  string renderForm(BusinessRoleViewModel model = BusinessRoleViewModel.init) {
    return string.init;
  }
}
