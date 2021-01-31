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
