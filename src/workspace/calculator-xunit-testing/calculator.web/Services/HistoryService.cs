namespace calculator.web.Services;

/// <summary>
/// Maintains session-scoped calculator history.
/// </summary>
public sealed class HistoryService
{
    private const int MaxRecords = 50;
    private readonly List<CalculationRecord> records = [];

    /// <summary>
    /// Gets newest-first calculation history.
    /// </summary>
    public IReadOnlyList<CalculationRecord> Records => records;

    /// <summary>
    /// Adds a calculation record to history.
    /// </summary>
    /// <param name="record">The completed calculation record.</param>
    public void Add(CalculationRecord record)
    {
        records.Insert(0, record);

        if (records.Count > MaxRecords)
        {
            records.RemoveRange(MaxRecords, records.Count - MaxRecords);
        }
    }

    /// <summary>
    /// Clears all history records.
    /// </summary>
    public void Clear() => records.Clear();
}