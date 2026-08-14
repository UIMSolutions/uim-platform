module uim.platform.architecture.domain.types;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct ArchitectureBlockId {
    mixin(IdTemplate);
}

struct SolutionBlockId {
    mixin(IdTemplate);
}

struct DataBlockId {
    mixin(IdTemplate);
}

struct BusinessBlockId {
    mixin(IdTemplate);
}

struct TechnologyBlockId {
    mixin(IdTemplate);
}
