---
title: CAIRA Well-Architected Framework Guidance
description: 'Expert guidance for applying Azure Well-Architected Framework best practices to CAIRA deployments'
applies_to_step: ["step-1", "post-step-1-optional"]
---
# CAIRA Well-Architected Framework Guidance

## Purpose

Provide concise, high-impact Azure Well-Architected improvement guidance that augments (never restates) existing CAIRA reference architectures. Focus exclusively on architectural considerations—not implementation plans, timelines, or deployment roadmaps.

Always assess all five pillars: Security, Cost Optimization, Operational Excellence, Performance Efficiency, Reliability.

## Assessment Workflow

1. **Research Current Best Practices**:
   - **MANDATORY**: Use Microsoft Docs tool to search for latest Azure Well-Architected Framework guidance
   - Search across all pillars: "Azure Well-Architected [pillar name]"
   - Research current Azure service recommendations for the selected architecture
   - Cross-reference findings with CAIRA capabilities to identify gaps

1. **Confirm with User**:
   - Present the scope of analysis
   - Wait for explicit confirmation before proceeding

1. **Assessment Process** (MANDATORY – perform both analyses; only Additional Considerations is user-visible):
   1. **Baseline Analysis (Internal Only – DO NOT OUTPUT)**: Internally enumerate what CAIRA already provides (modules & inherent capabilities). Use solely to avoid restating existing capabilities.
   1. **Additional Considerations (User Visible)**: Using Microsoft Docs research, identify ONLY architectural considerations not already satisfied by CAIRA baseline. Each consideration must:
      - Be based on Microsoft Docs research findings
      - Provide maximum 2 architectural design considerations per pillar
      - Be validated against official documentation

## Guidelines

- **Research First**: Always use Microsoft Docs tool to research current best practices
- **Maximum 2 considerations per pillar**: Focus on highest-impact recommendations only
- **Use exact pillar names**: Security, Cost Optimization, Operational Excellence, Performance Efficiency, Reliability
- **Advisory language only**: Use "consider", "evaluate", "design for" (not "implement", "deploy", "configure")
- **No implementation details**: Maintain architectural focus only—no timelines, roadmaps, or step-by-step instructions
- If no meaningful gap exists for a pillar: "No additional considerations"

## Output Format

Use this EXACT template structure:

```text
## Some Additional Considerations

**Well-Architected Pillars:**

**Security**
- [First consideration using "Consider" or "Evaluate"]
- [Second consideration using "Consider" or "Evaluate"]

**Cost Optimization**
- [First consideration]
- [Second consideration]

**Operational Excellence**
- [First consideration]
- [Second consideration]

**Performance Efficiency**
- [First consideration]
- [Second consideration]

**Reliability**
- [First consideration]
- [Second consideration]
```

Requirements:

- Use EXACTLY these headings
- List ALL 5 pillars with bold formatting
- Provide EXACTLY 2 bullet points per pillar
- Start each bullet with "Consider" or "Evaluate"

## Style Examples

**Security**

- Consider zonal redundancy design for storage architecture
- Evaluate customer-managed encryption keys for AI Foundry sensitive data

**Operational Excellence**

- Design Azure Monitor Agent governance architecture
- Consider CI/CD pipeline architectural patterns for governance
