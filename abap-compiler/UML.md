# UML — ABAP Compiler Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class AbapProgram {
        +ProgramId id
        +TenantId tenantId
        +ProgramType programType
        +string title
        +string language
        +string sourceCode
        +long createdAt
        +long updatedAt
        +bool isNull()
        +Json toJson()
        +static AbapProgram create(...)
    }

    class Token {
        +TokenId id
        +TokenType type
        +string value
        +size_t line
        +size_t column
        +Json toJson()
    }

    class Diagnostic {
        +DiagnosticSeverity severity
        +string message
        +size_t line
        +size_t column
        +string code
        +Json toJson()
    }

    class CompilationJob {
        +CompilationJobId id
        +TenantId tenantId
        +ProgramId programId
        +CompilationStatus status
        +Diagnostic[] diagnostics
        +string[] generatedCode
        +long startedAt
        +long finishedAt
        +bool isNull()
        +bool hasErrors()
        +Json toJson()
        +static CompilationJob create(...)
    }

    AbapProgram "1" --> "0..*" CompilationJob : compiles to
    CompilationJob "1" --> "0..*" Diagnostic : produces
```

---

## Class Diagram — Domain Services

```mermaid
classDiagram
    class AbapLexer {
        +Token[] tokenise(string source)
        -bool isKeyword(string word)
    }

    class AbapParser {
        +ParseResult parse(Token[] tokens)
        -ParsedStatement collectStatement()
    }

    class SemanticAnalyser {
        +Diagnostic[] analyse(ParsedStatement[] stmts)
    }

    class CodeGenerator {
        +string[] generate(ParsedStatement[] stmts)
    }

    class ParsedStatement {
        +string statementType
        +string[] tokens
        +size_t startLine
        +size_t endLine
        +Json toJson()
    }

    class ParseResult {
        +ParsedStatement[] statements
        +Diagnostic[] diagnostics
        +bool hasErrors()
    }

    AbapLexer ..> Token : produces
    AbapParser ..> ParsedStatement : produces
    AbapParser ..> ParseResult : returns
    SemanticAnalyser ..> Diagnostic : emits
    CodeGenerator ..> ParsedStatement : consumes
```

---

## Class Diagram — Application Layer

```mermaid
classDiagram
    class CompileUseCase {
        -AbapProgramRepository programRepo
        -CompilationJobRepository jobRepo
        -AbapLexer lexer
        -AbapParser parser
        -SemanticAnalyser analyser
        -CodeGenerator codeGen
        +CompileResponse compile(CompileRequest req)
    }

    class ManageProgramsUseCase {
        -AbapProgramRepository repo
        +CommandResult createProgram(CreateProgramRequest)
        +AbapProgram getProgram(tenantId, id)
        +AbapProgram[] listPrograms(tenantId)
        +CommandResult updateProgram(UpdateProgramRequest)
        +CommandResult deleteProgram(tenantId, id)
        +size_t countPrograms(tenantId)
    }

    class ManageJobsUseCase {
        -CompilationJobRepository repo
        +CompilationJob getJob(tenantId, id)
        +CompilationJob[] listJobs(tenantId)
        +CompilationJob[] listJobsForProgram(tenantId, pid)
        +CommandResult deleteJob(tenantId, id)
    }

    CompileUseCase --> AbapProgramRepository : reads source
    CompileUseCase --> CompilationJobRepository : saves job
    ManageProgramsUseCase --> AbapProgramRepository
    ManageJobsUseCase --> CompilationJobRepository
```

---

## Class Diagram — Ports (Hexagonal Interfaces)

```mermaid
classDiagram
    class AbapProgramRepository {
        <<interface>>
        +AbapProgram findById(tenantId, id)
        +AbapProgram[] find(tenantId)
        +void save(AbapProgram)
        +void update(AbapProgram)
        +void remove(AbapProgram)
        +size_t count(tenantId)
    }

    class CompilationJobRepository {
        <<interface>>
        +CompilationJob findById(tenantId, id)
        +CompilationJob[] findByProgram(tenantId, pid)
        +CompilationJob[] find(tenantId)
        +void save(CompilationJob)
        +void update(CompilationJob)
        +void remove(CompilationJob)
        +size_t count(tenantId)
    }

    class MemoryAbapProgramRepository {
        -AbapProgram[string] _store
    }

    class MemoryCompilationJobRepository {
        -CompilationJob[string] _store
    }

    AbapProgramRepository <|.. MemoryAbapProgramRepository
    CompilationJobRepository <|.. MemoryCompilationJobRepository
```

---

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart TB
    subgraph Driving["Driving Adapters (Left / Primary)"]
        HTTP["HTTP Controllers\n(ProgramController\nCompileController\nJobController\nHealthController)"]
        CLI["CLI (AbapCliRunner)"]
    end

    subgraph Application["Application Layer (Use Cases)"]
        UC1["CompileUseCase\n(Lex → Parse → Analyse → Generate)"]
        UC2["ManageProgramsUseCase"]
        UC3["ManageJobsUseCase"]
    end

    subgraph Domain["Domain (Pure Business Logic)"]
        Services["Domain Services\n(AbapLexer, AbapParser\nSemanticAnalyser, CodeGenerator)"]
        Entities["Entities\n(AbapProgram, Token\nDiagnostic, CompilationJob)"]
        Ports["Ports\n(AbapProgramRepository\nCompilationJobRepository)"]
    end

    subgraph Driven["Driven Adapters (Right / Secondary)"]
        Memory["In-Memory Repos\n(MemoryAbapProgramRepository\nMemoryCompilationJobRepository)"]
    end

    HTTP --> UC1
    HTTP --> UC2
    HTTP --> UC3
    CLI  --> UC1

    UC1 --> Services
    UC1 --> Ports
    UC2 --> Ports
    UC3 --> Ports

    Ports <|.. Memory
    Services --> Entities
```

---

## Sequence Diagram — Compile Request

```mermaid
sequenceDiagram
    participant Client
    participant CompileController
    participant CompileUseCase
    participant AbapProgramRepository
    participant AbapLexer
    participant AbapParser
    participant SemanticAnalyser
    participant CodeGenerator
    participant CompilationJobRepository

    Client->>CompileController: POST /api/v1/abap/compile
    CompileController->>CompileUseCase: compile(CompileRequest)
    CompileUseCase->>AbapProgramRepository: findById(tenantId, programId)
    AbapProgramRepository-->>CompileUseCase: AbapProgram
    CompileUseCase->>CompilationJobRepository: save(job{status=running})
    CompileUseCase->>AbapLexer: tokenise(source)
    AbapLexer-->>CompileUseCase: Token[]
    CompileUseCase->>AbapParser: parse(tokens)
    AbapParser-->>CompileUseCase: ParseResult
    CompileUseCase->>SemanticAnalyser: analyse(statements)
    SemanticAnalyser-->>CompileUseCase: Diagnostic[]
    CompileUseCase->>CodeGenerator: generate(statements)
    CodeGenerator-->>CompileUseCase: string[] (IR)
    CompileUseCase->>CompilationJobRepository: update(job{status=succeeded|failed})
    CompileUseCase-->>CompileController: CompileResponse
    CompileController-->>Client: 200/422 JSON
```

---

## State Diagram — CompilationJob Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : create()
    pending --> running : compile() starts
    running --> succeeded : no errors in diagnostics
    running --> failed : errors found
    running --> aborted : exception / timeout
    succeeded --> [*]
    failed --> [*]
    aborted --> [*]
```

---

## Enum Overview

```mermaid
classDiagram
    class ProgramType {
        <<enumeration>>
        report
        includeProgram
        modulePool
        functionGroup
        classPool
        interfacePool
        subroutinePool
        typePool
        transformation
        unknown
    }

    class TokenType {
        <<enumeration>>
        keyword
        identifier
        literal_integer
        literal_string
        operator
        comment
        period
        comma
        colon
        eof
    }

    class CompilationStatus {
        <<enumeration>>
        pending
        running
        succeeded
        failed
        aborted
    }

    class DiagnosticSeverity {
        <<enumeration>>
        error
        warning
        info
        hint
    }
```
