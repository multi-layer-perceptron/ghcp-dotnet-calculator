namespace calculator.web.Services;

/// <summary>
/// Stores recent calculator results for replay.
/// </summary>
public sealed class HistoryService
{
    private const int MaxItems = 50;
    private readonly List<CalculationRecord> records = [];

    /// <summary>
    /// Occurs when the history list changes.
    /// </summary>
    public event Action? OnHistoryChanged;

    /// <summary>
    /// Gets the newest-first calculation history.
    /// </summary>
    public IReadOnlyList<CalculationRecord> Records => records;

    /// <summary>
    /// Adds a new calculation record and trims old entries.
    /// </summary>
    /// <param name="record">The calculation to store.</param>
    public void Add(CalculationRecord record)
    {
        ArgumentNullException.ThrowIfNull(record);
        records.Insert(0, record);

        if (records.Count > MaxItems)
        {
            records.RemoveRange(MaxItems, records.Count - MaxItems);
        }

        OnHistoryChanged?.Invoke();
    }
}