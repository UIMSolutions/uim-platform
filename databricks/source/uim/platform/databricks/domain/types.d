module uim.platform.databricks.domain.types;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

struct WorkspaceId {
    mixin(IdTemplate);
}
struct ClusterId {
    mixin(IdTemplate);
}
struct NotebookId {
    mixin(IdTemplate);
}
struct JobId {
    mixin(IdTemplate);
}
struct JobRunId {
    mixin(IdTemplate);
}
struct DeltaTableId {
    mixin(IdTemplate);
}
struct DataProductId {
    mixin(IdTemplate);
}
struct MlExperimentId {
    mixin(IdTemplate);
}
struct MlModelId {
    mixin(IdTemplate);
}
struct SqlWarehouseId {
    mixin(IdTemplate);
}
