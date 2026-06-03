module uim.platform.analytics.infrastructure.container;

import vibe.db.mongo.mongo : connectMongoDB;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.domain;
import uim.platform.analytics.infrastructure.config;
import uim.platform.analytics.infrastructure.persistence;
import uim.platform.analytics.presentation;

struct Container {
  AssetRepository assetRepository;
  ManageAssetsUseCase manageAssetsUseCase;

  AnalyticsAssetsController assetsController;
  AnalyticsHealthController healthController;
  WebController webController;
  GuiController guiController;
  CliController cliController;
}

Container buildContainer(AppConfig config) {
  Container c;

  final switch (config.storage) {
    case StorageBackend.memory_:
      c.assetRepository = new MemoryAssetRepository();
      break;

    case StorageBackend.files_:
      c.assetRepository = new FileAssetRepository(config.dataPath);
      break;

    case StorageBackend.mongodb_:
      if (config.mongoUri.length == 0) {
        c.assetRepository = new MemoryAssetRepository();
      } else {
        auto db = connectMongoDB(config.mongoUri).getDatabase(config.mongoDb);
        c.assetRepository = new MongoAssetRepository(db["insight_assets"]);
      }
      break;
  }

  c.manageAssetsUseCase = new ManageAssetsUseCase(c.assetRepository);

  c.assetsController = new AnalyticsAssetsController(c.manageAssetsUseCase);
  c.healthController = new AnalyticsHealthController();
  c.webController = new WebController(c.manageAssetsUseCase);
  c.guiController = new GuiController(c.manageAssetsUseCase);
  c.cliController = new CliController(c.manageAssetsUseCase);

  return c;
}
