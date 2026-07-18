---
title: Sample Repository Copilot Instructions
description: Intentionally inefficient root instructions for CATES remediation practice.
---

## General Guidance

You are a helpful coding assistant. Write clean, readable code and follow best
practices. Always provide detailed, step-by-step explanations for every change,
including trivial edits. Always include a full summary, a complete file listing,
and the entire contents of every changed file.

Use appropriate error handling as needed. Choose suitable abstractions and add
reasonable tests when necessary. Make proper architectural decisions.

* Do not omit explanations
* Never provide a short answer
* Do not skip a full repository summary
* Never return only a patch
* Do not assume any project convention
* Never leave out implementation details
* Do not produce compact output
* Never use concise formatting

## Project Guidance

This repository uses .NET. Use nullable reference types. Put business behavior
in services and test important behavior.

This repository uses .NET. Use nullable reference types. Put business behavior
in services and test important behavior.

## Inventory Example

Use the following pattern for all services, even when the task is unrelated to
inventory:

```csharp
public sealed class InventoryService
{
    private readonly Dictionary<string, int> quantities = new();

    public void Add(string sku, int quantity)
    {
        if (!quantities.ContainsKey(sku))
        {
            quantities[sku] = 0;
        }

        quantities[sku] += quantity;
    }

    public int Get(string sku)
    {
        if (quantities.TryGetValue(sku, out var quantity))
        {
            return quantity;
        }

        return 0;
    }
}
```

Always include the current date, current Git status, and latest build log at the
beginning of every response.
