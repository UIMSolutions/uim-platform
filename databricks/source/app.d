module app;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

version (unittest) {
}
else {
  void main() {
    import std.stdio : writefln;
    import vibe.http.router : URLRouter;
    import vibe.http.server : HTTPServerSettings, listenHTTP;
    import vibe.core.core : runApplication;

    auto config    = loadConfig();
    auto container = buildContainer(config);
    auto router    = new URLRouter();

    // === Workspaces ===
    container.workspaceController.registerRoutes(router);

    // === Compute (Clusters) ===
    container.clusterController.registerRoutes(router);

    // === Notebooks ===
    container.notebookController.registerRoutes(router);

    // === Jobs & Workflows ===
    container.jobController.registerRoutes(router);
    container.jobRunController.registerRoutes(router);

    // === Delta Tables (Unity Catalog) ===
    container.deltaTableController.registerRoutes(router);

    // === Data Products (SAP BDC Integration) ===
    container.dataProductController.registerRoutes(router);

    // === Machine Learning (MLflow) ===
    container.mlExperimentController.registerRoutes(router);
    container.mlModelController.registerRoutes(router);

    // === SQL Analytics ===
    container.sqlWarehouseController.registerRoutes(router);

    // === Health ===
    container.healthController.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port          = config.port;
    settings.bindAddresses = [config.host];

    listenHTTP(settings, router);

    writefln("=============================================================");
    writefln("  SAP Databricks Platform Service");
    writefln("  Listening on %s:%d", config.host, config.port);
    writefln("-------------------------------------------------------------");
    writefln("  Workspaces   : POST/GET /api/v1/databricks/workspaces");
    writefln("  Clusters     : POST/GET /api/v1/databricks/clusters");
    writefln("  Notebooks    : POST/GET /api/v1/databricks/notebooks");
    writefln("  Jobs         : POST/GET /api/v1/databricks/jobs");
    writefln("  Job Runs     : POST/GET /api/v1/databricks/jobruns");
    writefln("  Delta Tables : POST/GET /api/v1/databricks/tables");
    writefln("  Data Products: POST/GET /api/v1/databricks/dataproducts");
    writefln("  ML Experiments:POST/GET /api/v1/databricks/experiments");
    writefln("  ML Models    : POST/GET /api/v1/databricks/models");
    writefln("  SQL Warehouses:POST/GET /api/v1/databricks/warehouses");
    writefln("  Health       : GET     /api/v1/health");
    writefln("=============================================================");

    runApplication();
  }
}
