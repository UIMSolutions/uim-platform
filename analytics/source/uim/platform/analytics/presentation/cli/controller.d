module uim.platform.analytics.presentation.cli.controller;

import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.cli.model;
import uim.platform.analytics.presentation.cli.view;

class CliController {
  private ManageAssetsUseCase useCase;
  private CliView view;

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
