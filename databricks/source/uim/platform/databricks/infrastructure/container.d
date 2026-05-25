module uim.platform.databricks.infrastructure.container;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// DI container — wires all architecture layers together.
struct Container {
  // --- Repositories (driven adapters) ---
  MemoryWorkspaceRepository    workspaceRepo;
  MemoryClusterRepository      clusterRepo;
  MemoryNotebookRepository     notebookRepo;
  MemoryJobRepository          jobRepo;
  MemoryJobRunRepository       jobRunRepo;
  MemoryDeltaTableRepository   deltaTableRepo;
  MemoryDataProductRepository  dataProductRepo;
  MemoryMlExperimentRepository mlExperimentRepo;
  MemoryMlModelRepository      mlModelRepo;
  MemorySqlWarehouseRepository sqlWarehouseRepo;

  // --- Use cases (application layer) ---
  ManageWorkspacesUseCase    manageWorkspaces;
  ManageClustersUseCase      manageClusters;
  ManageNotebooksUseCase     manageNotebooks;
  ManageJobsUseCase          manageJobs;
  ManageJobRunsUseCase       manageJobRuns;
  ManageDeltaTablesUseCase   manageDeltaTables;
  ManageDataProductsUseCase  manageDataProducts;
  ManageMlExperimentsUseCase manageMlExperiments;
  ManageMlModelsUseCase      manageMlModels;
  ManageSqlWarehousesUseCase manageSqlWarehouses;

  // --- Controllers (driving adapters / presentation) ---
  WorkspaceController    workspaceController;
  ClusterController      clusterController;
  NotebookController     notebookController;
  JobController          jobController;
  JobRunController       jobRunController;
  DeltaTableController   deltaTableController;
  DataProductController  dataProductController;
  MlExperimentController mlExperimentController;
  MlModelController      mlModelController;
  SqlWarehouseController sqlWarehouseController;
  HealthController       healthController;
}

/// Build the full dependency graph.
Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.workspaceRepo    = new MemoryWorkspaceRepository();
  c.clusterRepo      = new MemoryClusterRepository();
  c.notebookRepo     = new MemoryNotebookRepository();
  c.jobRepo          = new MemoryJobRepository();
  c.jobRunRepo       = new MemoryJobRunRepository();
  c.deltaTableRepo   = new MemoryDeltaTableRepository();
  c.dataProductRepo  = new MemoryDataProductRepository();
  c.mlExperimentRepo = new MemoryMlExperimentRepository();
  c.mlModelRepo      = new MemoryMlModelRepository();
  c.sqlWarehouseRepo = new MemorySqlWarehouseRepository();

  // Application use cases
  c.manageWorkspaces    = new ManageWorkspacesUseCase(c.workspaceRepo);
  c.manageClusters      = new ManageClustersUseCase(c.clusterRepo);
  c.manageNotebooks     = new ManageNotebooksUseCase(c.notebookRepo);
  c.manageJobs          = new ManageJobsUseCase(c.jobRepo);
  c.manageJobRuns       = new ManageJobRunsUseCase(c.jobRunRepo);
  c.manageDeltaTables   = new ManageDeltaTablesUseCase(c.deltaTableRepo);
  c.manageDataProducts  = new ManageDataProductsUseCase(c.dataProductRepo);
  c.manageMlExperiments = new ManageMlExperimentsUseCase(c.mlExperimentRepo);
  c.manageMlModels      = new ManageMlModelsUseCase(c.mlModelRepo);
  c.manageSqlWarehouses = new ManageSqlWarehousesUseCase(c.sqlWarehouseRepo);

  // Presentation controllers
  c.workspaceController    = new WorkspaceController(c.manageWorkspaces);
  c.clusterController      = new ClusterController(c.manageClusters);
  c.notebookController     = new NotebookController(c.manageNotebooks);
  c.jobController          = new JobController(c.manageJobs);
  c.jobRunController       = new JobRunController(c.manageJobRuns);
  c.deltaTableController   = new DeltaTableController(c.manageDeltaTables);
  c.dataProductController  = new DataProductController(c.manageDataProducts);
  c.mlExperimentController = new MlExperimentController(c.manageMlExperiments);
  c.mlModelController      = new MlModelController(c.manageMlModels);
  c.sqlWarehouseController = new SqlWarehouseController(c.manageSqlWarehouses);
  c.healthController       = new HealthController("databricks");

  return c;
}
