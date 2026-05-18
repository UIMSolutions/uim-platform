/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.service_binding;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.service_binding;
import uim.platform.abap_environment.presentation.gui.models.service_binding;

mixin(ShowModule!());

class ServiceBindingGuiController {
  private ManageServiceBindingsUseCase usecase;
  private ServiceBindingWindow view;
  private ServiceBindingGuiModel model;

  this(ManageServiceBindingsUseCase usecase, ServiceBindingWindow view, ServiceBindingGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
