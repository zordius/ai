---
description: Audit the AI config directory and get improvement suggestions
allowed-tools: Task
---

# Review AI Config Directory

Use the Task tool to launch the `system-consultant` agent with the following prompt:

```
Audit the entire AI config directory and README. Review all agents, skills,
commands, settings, KB files, docs, and templates. Apply the governing rules
from the system's rule docs and generate a full audit report with issues and
recommendations.
```

The consultant will return a structured audit report. Present this report to the user.

## After Receiving the Audit Report

1. Display the full audit report to the user
2. Ask if they want you to implement any of the recommended changes
3. If yes, implement changes following the consultant's guidance — gate any
   mutation on explicit user confirmation (see "Surface before applying
   delegated results" in PRINCIPLES.md)
