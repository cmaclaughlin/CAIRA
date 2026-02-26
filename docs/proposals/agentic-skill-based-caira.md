# Agentic Skill-based CAIRA

## Background

CAIRA currently provides enterprise-grade reference architectures for AI/ML workloads on Azure, focusing primarily on infrastructure deployment through Terraform modules. CAIRA includes GitHub Copilot chat modes (agents) such as the CAIRA Assistant, Task Planner, Prompt Builder, and ADR Creation Coach that provide interactive deployment guidance within the repository.

While this foundation is valuable, the current implementation requires users to work within the cloned CAIRA repository to access these capabilities. Additionally, users frequently encounter a "Now what?" moment after infrastructure provisioning, as guidance focuses on infrastructure and doesn't extend to full-stack application development and deployment patterns.

## Problem Statement

**Current State:**

- CAIRA has GitHub Copilot chat modes (CAIRA Assistant, Task Planner, Prompt Builder, ADR Creation Coach) that provide interactive guidance
- Chat modes only function within the cloned CAIRA repository context
- Users cannot leverage CAIRA expertise directly in their own project repositories
- Guidance is limited to infrastructure-as-code and lacks full-stack application development patterns
- No portable skill format for use across different agentic coding platforms (Cursor, Windsurf, etc.)

**Desired State:**

- CAIRA knowledge accessible as a portable skill that works in any user repository
- Compatible with multiple agentic coding platforms (GitHub Copilot, Cursor, Windsurf, etc.)
- End-to-end guidance covering infrastructure, application layer, and deployment
- Repository-agnostic skill that provides CAIRA expertise without requiring repository cloning
- Seamless progression from infrastructure to fully deployed agentic AI applications
- Skill delivery methods: [skills.sh](https://skills.sh/), [apm](https://github.com/microsoft/apm)

## Goals & Objectives

1. **Enable In-Repository Development**
   - Users can work entirely within their own project repositories
   - No requirement to clone or fork the CAIRA repository
   - CAIRA knowledge delivered as contextual guidance through agentic coding platforms

1. **Provide Full-Stack Coverage**
   - Extend beyond IaC to cover complete application development lifecycle
   - Include patterns for application architecture, agent implementation, and deployment
   - Eliminate the "Now what?" gap after infrastructure provisioning

## Primary User Story

**As a** web application developer
**I want to** add an intelligent support chatbot to my existing website
**So that** I can provide automated customer assistance powered by Azure AI

**Acceptance Criteria:**

- Guided through infrastructure provisioning (Azure AI Foundry, Container Registry, Container Apps)
- Receive architectural guidance for 3-layer agent-based application (agent layer, API layer, presentation layer)
- Obtain deployment patterns for containerized workloads
- Complete implementation without leaving my project repository

## Target Use Case: Support Chatbot Integration

**Scenario Flow:**

1. User has existing website codebase in their own repository
1. User clones CAIRA samples repository locally (_for PoC only_)
1. User invokes CAIRA skill with intent: "Add support chatbot"
1. Skill provides:
   - Infrastructure guidance from public CAIRA repository (AI Foundry, storage, networking)
   - Agent architecture patterns from local CAIRA samples (3-layer design)
   - API layer implementation guidance (TypeScript/OpenAI SDK)
   - Deployment configuration (container orchestration)
1. User follows guidance to implement and deploy solution in their repository

## Appendix

### Related Documentation

- CAIRA Chat Modes: `/docs/chat_modes.md`
- GitHub Copilot Instructions: `/.github/copilot-instructions.md`
- CAIRA Reference Architectures: `/reference_architectures/`
- CAIRA Modules: `/modules/`
- Development Workflow: `/docs/contributing/development_workflow.md`
