namespace calculator.tests;

using calculator.web.Services;

public class HistoryServiceTests
{
    private readonly HistoryService _sut;

    public HistoryServiceTests()
    {
        _sut = new HistoryService();
    }

    private static CalculationRecord CreateRecord(int value) => new(
        $"{value} + 0",
        value,
        DateTimeOffset.UnixEpoch.AddMinutes(value));

    [Fact]
    public void GivenExistingRecords_WhenClear_RemovesAllRecords()
    {
        _sut.Add(CreateRecord(1));

        _sut.Clear();

        Assert.Empty(_sut.Records);
    }

    [Fact]
    public void GivenMoreThanFiftyRecords_WhenAdd_KeepsNewestFiftyRecords()
    {
        for (var value = 1; value <= 55; value++)
        {
            _sut.Add(CreateRecord(value));
        }

        Assert.Equal(50, _sut.Records.Count);
        Assert.Equal(55, _sut.Records[0].Result);
        Assert.Equal(6, _sut.Records[^1].Result);
    }

    [Fact]
    public void GivenRecords_WhenAdd_StoresNewestFirst()
    {
        _sut.Add(CreateRecord(1));
        _sut.Add(CreateRecord(2));

        Assert.Equal(2, _sut.Records[0].Result);
        Assert.Equal(1, _sut.Records[1].Result);
    }
}