/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.presentation.cli.controller;

import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.cli.model;
import uim.platform.analytics.presentation.cli.view;

class CliController {
  protected ManageAssetsUseCase useCase;
  protected CliView view;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
    this.view = CliView();
  }

  string renderOverview(string tenantId = "default") {
    auto items = useCase.listAssets(tenantId);

    CliAssetListModel model;
    model.tenantId = tenantId;
    model.count = items.length;
    foreach (item; items) model.assetNames ~= item.name;

    return view.renderAssetList(model);
  }
}
