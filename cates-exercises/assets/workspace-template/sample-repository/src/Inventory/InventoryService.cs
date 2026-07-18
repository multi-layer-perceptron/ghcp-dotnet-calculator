#nullable enable

using System;
using System.Collections.Generic;

namespace Cates.Sample.Inventory;

/// <summary>
/// Tracks available inventory quantities for the CATES sample repository.
/// </summary>
public sealed class InventoryService
{
    private readonly Dictionary<string, int> quantities = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Adds an inventory quantity for a stock-keeping unit.
    /// </summary>
    /// <param name="sku">The stock-keeping unit identifier.</param>
    /// <param name="quantity">The positive quantity to add.</param>
    /// <exception cref="ArgumentException">Thrown when <paramref name="sku"/> is empty.</exception>
    /// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="quantity"/> is not positive.</exception>
    public void Add(string sku, int quantity)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sku);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(quantity);

        quantities[sku] = Get(sku) + quantity;
    }

    /// <summary>
    /// Gets the available quantity for a stock-keeping unit.
    /// </summary>
    /// <param name="sku">The stock-keeping unit identifier.</param>
    /// <returns>The available quantity, or zero when the item is unknown.</returns>
    public int Get(string sku)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sku);
        return quantities.GetValueOrDefault(sku);
    }
}