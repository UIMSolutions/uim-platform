/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.business_user;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.business_user;
import uim.platform.abap_environment.presentation.gui.models.business_user;

// mixin(ShowModule!());

class BusinessUserGuiController {
  private ManageBusinessUsersUseCase usecase;
  private BusinessUserWindow view;
  private BusinessUserGuiModel model;

  this(ManageBusinessUsersUseCase usecase, BusinessUserWindow view, BusinessUserGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
