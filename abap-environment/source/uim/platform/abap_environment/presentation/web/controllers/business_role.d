/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.controllers.business_role;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class BusinessRoleWebController : ManageController {
  private ManageBusinessRolesUseCase usecase;

  this(ManageBusinessRolesUseCase usecase) {
    this.usecase = usecase;
  }
}
