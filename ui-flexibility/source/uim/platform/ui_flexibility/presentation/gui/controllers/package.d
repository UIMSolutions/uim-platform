/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.gui.controllers;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// GUI controller: wires UI events to use cases and updates models.
class FlexChangeGuiController {
  private ManageFlexChangesUseCase usecase;
  private FlexChangeGuiModel model_;

  this(ManageFlexChangesUseCase usecase) {
    this.usecase = usecase;
    model_ = new FlexChangeGuiModel(FlexChange.init);
  }

  FlexChangeGuiModel model() { return model_; }

  /// Called when user selects a change in the GUI list.
  void onSelectChange(TenantId tenantId, FlexChangeId id) {
    auto c = usecase.getChange(tenantId, id);
    if (!c.isNull) model_.setValue(c);
  }
}

/// GUI controller for FlexVariant list panel.
class FlexVariantGuiController {
  private ManageFlexVariantsUseCase usecase;
  private FlexVariantListGuiModel model_;

  this(ManageFlexVariantsUseCase usecase) {
    this.usecase = usecase;
    model_ = new FlexVariantListGuiModel();
  }

  FlexVariantListGuiModel model() { return model_; }

  /// Called when user requests a refresh of the variant list.
  void onRefresh(TenantId tenantId) {
    auto vs = usecase.listVariants(tenantId);
    model_.setValues(vs);
  }
}
