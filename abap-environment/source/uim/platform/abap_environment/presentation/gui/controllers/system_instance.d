/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.system_instance;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.system_instance;
import uim.platform.abap_environment.presentation.gui.models.system_instance;

// mixin(ShowModule!());

class SystemInstanceGuiController {
  private ManageSystemInstancesUseCase usecase;
  private SystemInstanceWindow view;
  private SystemInstanceGuiModel model;

  this(ManageSystemInstancesUseCase usecase, SystemInstanceWindow view, SystemInstanceGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
