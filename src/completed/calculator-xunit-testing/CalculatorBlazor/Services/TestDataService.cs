namespace CalculatorBlazor.Services;

/// <summary>
/// Represents a single test case for the calculator.
/// </summary>
public class TestCase
{
    public double FirstNumber { get; set; }
    public double SecondNumber { get; set; }
    public string Operation { get; set; } = string.Empty;
    public double ExpectedValue { get; set; }
    public string Description { get; set; } = string.Empty;
    public double ActualValue { get; set; }
    public string Result { get; set; } = "pending";
} // end class TestCase

/// <summary>
/// Service for loading and managing calculator test data from CSV file.
/// </summary>
public class TestDataService
{
    private readonly string _csvPath;

    public TestDataService(IWebHostEnvironment env)
    {
        // Path to the test data CSV file
        _csvPath = Path.Combine(env.ContentRootPath, "TestData", "calculator-test-data.csv");
    } // end constructor

    /// <summary>
    /// Loads test data from the CSV file.
    /// </summary>
    /// <returns>A list of test cases.</returns>
    public List<TestCase> LoadTestData()
    {
        var testCases = new List<TestCase>();

        if (!File.Exists(_csvPath))
        {
            return testCases;
        } // end if

        try
        {
            var lines = File.ReadAllLines(_csvPath);
            
            // Skip header row
            for (int i = 1; i < lines.Length; i++)
            {
                var parts = lines[i].Split(',');
                
                if (parts.Length >= 5)
                {
                    var testCase = new TestCase
                    {
                        FirstNumber = double.Parse(parts[0].Trim()),
                        SecondNumber = double.Parse(parts[1].Trim()),
                        Operation = parts[2].Trim(),
                        ExpectedValue = double.Parse(parts[3].Trim()),
                        Description = parts[4].Trim()
                    };
                    
                    testCases.Add(testCase);
                } // end if
            } // end for
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error loading test data: {ex.Message}");
        } // end catch

        return testCases;
    } // end LoadTestData
} // end class TestDataService
