/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.business_role;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.business_role;
import uim.platform.abap_environment.presentation.gui.models.business_role;

// mixin(ShowModule!());

class BusinessRoleGuiController {
  private ManageBusinessRolesUseCase usecase;
  private BusinessRoleWindow view;
  private BusinessRoleGuiModel model;

  this(ManageBusinessRolesUseCase usecase, BusinessRoleWindow view, BusinessRoleGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
