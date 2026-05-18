# UML — SAP Build Code Platform Service

## 1. Domain Entity Model

```plantuml
@startuml Domain Entities

entity Project {
  + id: ProjectId
  + tenantId: string
  + name: string
  + description: string
  + type: ProjectType
  + techStack: TechStack
  + status: ProjectStatus
  + ownerEmail: string
  + repositoryUrl: string
  + defaultBranch: string
  + tags: string[]
  + createdAt: string
  + updatedAt: string
}

entity DevSpace {
  + id: DevSpaceId
  + tenantId: string
  + projectId: ProjectId
  + name: string
  + displayName: string
  + status: DevSpaceStatus
  + technicalUser: string
  + url: string
  + storageGiB: ushort
  + ramGiB: ushort
  + ideUrl: string
}

entity ProjectTemplate {
  + id: TemplateId
  + tenantId: string
  + name: string
  + displayName: string
  + description: string
  + category: string
  + projectType: ProjectType
  + techStack: TechStack
  + version_: string
  + author: string
  + isBuiltIn: bool
  + parameters: string[]
}

entity Pipeline {
  + id: PipelineId
  + tenantId: string
  + projectId: ProjectId
  + name: string
  + description: string
  + stage: PipelineStage
  + repositoryUrl: string
  + branch: string
  + configFilePath: string
  + isActive: bool
  + triggerType: string
  + schedule: string
}

entity BuildJob {
  + id: BuildJobId
  + tenantId: string
  + pipelineId: PipelineId
  + projectId: ProjectId
  + commitSha: string
  + branch: string
  + status: JobStatus
  + startedAtMs: long
  + finishedAtMs: long
  + triggeredBy: string
  + logUrl: string
  + artifactIds: string[]
  + errorMessage: string
}

entity Deployment {
  + id: DeploymentId
  + tenantId: string
  + projectId: ProjectId
  + buildJobId: BuildJobId
  + artifactVersion: string
  + targetEnvironment: DeploymentEnvironment
  + status: DeploymentStatus
  + targetOrg: string
  + targetSpace: string
  + targetUrl: string
  + deployedBy: string
  + deployedAtMs: long
  + errorMessage: string
}

entity AIRequest {
  + id: AIRequestId
  + tenantId: string
  + projectId: ProjectId
  + requestedBy: string
  + generationType: AIGenerationType
  + prompt: string
  + generatedCode: string
  + targetFilePath: string
  + status: AIRequestStatus
  + modelUsed: string
  + errorMessage: string
  + completedAtMs: long
}

entity ServiceBinding {
  + id: ServiceBindingId
  + tenantId: string
  + projectId: ProjectId
  + serviceName: string
  + servicePlan: string
  + bindingLabel: string
  + status: BindingStatus
  + instanceId: string
}

Project "1" --> "0..*" DevSpace    : hosts
Project "1" --> "0..*" Pipeline    : defines
Project "1" --> "0..*" Deployment  : deploys to
Project "1" --> "0..*" AIRequest   : generates via
Project "1" --> "0..*" ServiceBinding : bound to
Pipeline "1" --> "0..*" BuildJob   : triggers

@enduml
```

---

## 2. Hexagonal Architecture

```plantuml
@startuml Hexagonal Architecture

package "Driving Adapters" {
  [HTTP Client] as HC
}

package "Presentation (HTTP)" {
  [ProjectController]        as PC
  [DevSpaceController]       as DSC
  [TemplateController]       as TC
  [PipelineController]       as PLC
  [BuildJobController]       as BJC
  [DeploymentController]     as DC
  [AIRequestController]      as AIC
  [ServiceBindingController] as SBC
  [HealthController]         as HTC
}

package "Application" {
  [ManageProjectsUseCase]        as MPU
  [ManageDevSpacesUseCase]       as MDU
  [ManageTemplatesUseCase]       as MTU
  [ManagePipelinesUseCase]       as MPLU
  [ManageBuildJobsUseCase]       as MBJU
  [ManageDeploymentsUseCase]     as MDpU
  [ManageAIRequestsUseCase]      as MAIU
  [ManageServiceBindingsUseCase] as MSBU
}

package "Domain" {
  [Project Entity]         as PE
  [DevSpace Entity]        as DSE
  [Template Entity]        as TE
  [Pipeline Entity]        as PLE
  [BuildJob Entity]        as BJE
  [Deployment Entity]      as DE
  [AIRequest Entity]       as AIE
  [ServiceBinding Entity]  as SBE
  [ProjectValidator]       as PV
  [QuotaService]           as QS

  interface ProjectRepository        as PR
  interface DevSpaceRepository       as DSR
  interface TemplateRepository       as TR
  interface PipelineRepository       as PLR
  interface BuildJobRepository       as BJR
  interface DeploymentRepository     as DR
  interface AIRequestRepository      as AIR
  interface ServiceBindingRepository as SBR
}

package "Driven Adapters (In-Memory)" {
  [MemoryProjectRepository]        as MPR
  [MemoryDevSpaceRepository]       as MDSR
  [MemoryTemplateRepository]       as MTR
  [MemoryPipelineRepository]       as MPLR
  [MemoryBuildJobRepository]       as MBJR
  [MemoryDeploymentRepository]     as MDR
  [MemoryAIRequestRepository]      as MAIR
  [MemoryServiceBindingRepository] as MSBR
}

HC --> PC
HC --> DSC
HC --> TC
HC --> PLC
HC --> BJC
HC --> DC
HC --> AIC
HC --> SBC
HC --> HTC

PC  --> MPU
DSC --> MDU
TC  --> MTU
PLC --> MPLU
BJC --> MBJU
DC  --> MDpU
AIC --> MAIU
SBC --> MSBU

MPU  --> PR
MDU  --> DSR
MTU  --> TR
MPLU --> PLR
MBJU --> BJR
MDpU --> DR
MAIU --> AIR
MSBU --> SBR

MPR  ..|> PR
MDSR ..|> DSR
MTR  ..|> TR
MPLR ..|> PLR
MBJR ..|> BJR
MDR  ..|> DR
MAIR ..|> AIR
MSBR ..|> SBR

@enduml
```

---

## 3. CI/CD Pipeline Execution Sequence

```plantuml
@startuml CI/CD Trigger Sequence

actor Developer
participant "BuildJobController" as BJC
participant "ManageBuildJobsUseCase" as MBJU
participant "PipelineRepository" as PLR
participant "BuildJobRepository" as BJR

Developer -> BJC : POST /api/v1/buildcode/buildjobs\n{pipelineId, commitSha, branch, triggeredBy}
BJC -> MBJU : trigger(tenantId, TriggerBuildRequest)
MBJU -> PLR  : findById(tenantId, pipelineId)
PLR --> MBJU : Pipeline
MBJU -> MBJU : validate pipeline active
MBJU -> BJR  : save(BuildJob{status=queued})
BJR --> MBJU : ok
MBJU --> BJC : CommandResult{success, id}
BJC --> Developer : 201 Created {id}

@enduml
```

---

## 4. AI Generation Request Flow

```plantuml
@startuml AI Generation Flow

actor Developer
participant "AIRequestController" as AIC
participant "ManageAIRequestsUseCase" as MAIU
participant "ProjectValidator" as PV
participant "AIRequestRepository" as AIR

Developer -> AIC : POST /api/v1/buildcode/ai/generate\n{projectId, prompt, generationType, ...}
AIC -> MAIU : generate(tenantId, AIGenerateRequest)
MAIU -> PV  : validatePrompt(prompt)
PV --> MAIU : [] (no errors)
MAIU -> AIR : save(AIRequest{status=pending, modelUsed="Joule"})
AIR --> MAIU : ok
MAIU --> AIC : CommandResult{success, id}
AIC --> Developer : 202 Accepted {id}

note over Developer, AIR
  Asynchronous processing of the AI request
  happens out of band (model/worker layer).
  Client polls GET /api/v1/buildcode/ai/requests/{id}
  until status = "completed".
end note

@enduml
```

---

## 5. Deployment State Machine

```plantuml
@startuml Deployment Status

[*] --> pending : Deployment created

pending      --> deploying    : Deploy started
deploying    --> succeeded    : Deployment ok
deploying    --> failed       : Deployment error
deploying    --> rolling_back : Rollback triggered
rolling_back --> failed       : Rollback complete

succeeded    --> [*]
failed       --> [*]

@enduml
```
