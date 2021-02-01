/// Class to hold some basic statistics on the SQL-statements executed on the system. <br/>
/// This was inspired by the article "monitoring SQL query Performance" by David Loveluck (https://community.intersystems.com/post/apm-%E2%80%93-monitoring-sql-query-performance)
Class BeVo.SQLMon.Data.BasicSQLStats Extends %Persistent
{

/// The date the query was run
Property Date As %Date;

/// The start of the intervall for which data was collected
Property FromTime As %Time;

/// The end of the interval for which data was collected
Property ToTime As %Time;

/// The number of times the query was called during this time-frame
Property TotalHits As %Integer;

/// The total time taken to execute the query within the time-frame
Property TotalTime As %Numeric;

/// The routine from which the query was called
Property RoutineName As %String(MAXLEN = 1024);

/// The namespace in which the query was run
Property Namespace As %String;

/// The Variance the different runs for the query have. Attention, this will be "cumulative" if the time-frame is less than a day
Property Variance As %Numeric(SCALE = 4);

/// The hash value of a Query
Property Hash As %String;

/// The actual query-text for the query
Property QueryText As %String(MAXLEN = 9999);

/// Index on the hash and date to optimise agregating on date for a query
Index idxHashDate On (Hash, Date);

/// Get the last time we collected date for the given query in a given namespace on a given date
ClassMethod GetLastTime(queryHash As %String, namespace As %String, date As %Date) As %Time
{
    Set lastTime = 0
    &SQL(SELECT ToTime into :time FROM BeVO_SQLMON_Data.BasicSQLStats 
            WHERE Hash = :queryHash
            AND "Date" = :date
            AND Namespace = :namespace
            ORDER BY ToTime DESC)
    if ('SQLCODE) { set lastTime = time }
    Return lastTime
}

/// Get the total counts for a given query on a given date in a given namespace
ClassMethod GetTotals(queryHash As %String, namespace As %String, date As %Date) As %DynamicObject
{
    set totals = {}
    set totals.totalHits = ..GetTotalHits(queryHash,namespace,date)
    set totals.totalTime = ..GetTotalTime(queryHash,namespace,date)
    return totals
}

/// Get The total time a given query ran on a given date in a given namespace
ClassMethod GetTotalTime(queryHash As %String, namespace As %String, date As %Date) As %Numeric
{
    set time = 0
    &SQL(SELECT sum(TotalTime) into :totalTime
            FROM BeVO_SQLmon_Data.BasicSQLStats
            WHERE Hash = :queryHash
            AND Namespace = :namespace
            AND "Date" = :date
            GROUP BY Hash)
    if ('SQLCODE) { set time = totalTime }
    return time
}

/// Get The total times a given query ran on a given date in a given namespace
ClassMethod GetTotalHits(queryHash As %String, namespace As %String, date As %Date) As %Numeric
{
    set hits = 0
    &SQL(SELECT sum(TotalHits) into :totalHits
            FROM BeVO_SQLmon_Data.BasicSQLStats
            WHERE Hash = :queryHash
            AND Namespace = :namespace
            AND "Date" = :date
            GROUP BY Hash)
    if ('SQLCODE) { set hits = totalHits }
    return hits
}

Storage Default
{
<Data name="BasicSQLStatsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Date</Value>
</Value>
<Value name="3">
<Value>Time</Value>
</Value>
<Value name="4">
<Value>TotalHits</Value>
</Value>
<Value name="5">
<Value>FromTime</Value>
</Value>
<Value name="6">
<Value>ToTime</Value>
</Value>
<Value name="7">
<Value>TotalTime</Value>
</Value>
<Value name="8">
<Value>RoutineName</Value>
</Value>
<Value name="9">
<Value>Namespace</Value>
</Value>
<Value name="10">
<Value>Variance</Value>
</Value>
<Value name="11">
<Value>Hash</Value>
</Value>
<Value name="12">
<Value>QueryText</Value>
</Value>
</Data>
<DataLocation>^BeVo.SQLMonC89F.BasicSQLStatsD</DataLocation>
<DefaultData>BasicSQLStatsDefaultData</DefaultData>
<IdLocation>^BeVo.SQLMonC89F.BasicSQLStatsD</IdLocation>
<IndexLocation>^BeVo.SQLMonC89F.BasicSQLStatsI</IndexLocation>
<StreamLocation>^BeVo.SQLMonC89F.BasicSQLStatsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
