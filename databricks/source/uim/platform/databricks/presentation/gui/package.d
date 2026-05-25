module uim.platform.databricks.presentation.gui;

/++
  GUI presentation layer — MVC pattern with GTK (planned).

  Model      : Observable wrappers around domain entities
  View       : gtk-d widget panels
  Controller : GTK signal handlers

  Planned panels:
    WorkspacePanelController   — workspace selector + status badges
    ClusterPanelController     — cluster list, start/stop buttons, auto-scaling
    NotebookPanelController    — notebook tree view, embedded code editor
    JobPanelController         — job scheduler, run status monitor
    DeltaTablePanelController  — Unity Catalog browser, schema explorer
    DataProductPanelController — SAP BDC data product sync wizard
    MlExperimentPanelController— MLflow run comparator
    MlModelPanelController     — model registry, stage promotion dialogs
    SqlWarehousePanelController— warehouse start/stop, query editor
+/
