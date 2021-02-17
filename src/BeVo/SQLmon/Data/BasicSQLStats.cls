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

/// Get the statistics in a dynamic array of dynamic objects.
/// <PARAMETER>namespace:  the namespace for which to get the statistics. Leave blanck for all namespaces</PARAMETER>
/// <PARAMETER>fromDate: the start date for the stats</PARAMETER>
/// <PARAMETER>fromTime: the start time for the stats, will only be taken into account id start date is given</PARAMETER>
/// <PARAMETER>toDate: the end date for the stats</PARAMETER>
/// <PARAMETER>toTime: the end time for the stats, will only be taken into account id end date is given</PARAMETER>
/// <PARAMETER>sortBy: the field to sort the data by; this can be "hits" (default) to sort by the number of hits or "time" to sort by the time the query ran.</PARAMETER>
ClassMethod GetStats(namespace As %String = "", fromDate As %Date = "", fromTime As %Time = "", toDate As %Date = "", toTime As %Time = "", sortBy As %String = "hits") As %DynamicArray
{
    set result = []
    set qry = 2
    set qry(1) = "SELECT sum(TotalHits) as hits,sum(TotalTime) as ""time"",Namespace,Hash"
    set qry(2) = "FROM BeVo_SQLMon_Data.BasicSQLStats"
    set dynd = 0
    if namespace '= "" {
        set qry = qry + 1
        set qry(qry) = "WHERE namespace = ?"
        set dynd = dynd + 1
        set dynd(dynd) = namespace
    }
    if fromDate '= "" {
        set qry = qry + 1
        i qry > 3 { set qry(qry) = "AND ""Date"" >= ?" }
        else { set qry(qry) = "WHERE ""Date"" >= ?" }
        set dynd = dynd + 1
        set dynd(dynd) = fromDate
        if fromTime '= "" {
            set qry = qry + 1
            set qry(qry) = "AND FromTime >= ?"
            set dynd = dynd + 1
            set dynd(dynd) = fromTime
        }
    }
    if toDate '= "" {
        set qry = qry + 1
        i qry > 3 { set qry(qry) = "AND ""Date"" <= ?" }
        else { set qry(qry) = "WHERE ""Date"" <= ?" }
        set dynd = dynd + 1
        set dynd(dynd) = toDate
        if toTime '= "" {
            set qry = qry + 1
            set qry(qry) = "AND ToTime <= ?"
            set dynd = dynd + 1
            set dynd(dynd) = toTime
        }
    }    
    set qry = qry + 1
    set qry(qry) = "GROUP BY Namespace,Hash"
    set qry = qry + 1
    set qry(qry) = "ORDER BY hits desc"
    if sortBy = "time" {
        set qry(qry) = "ORDER BY ""time"" desc"
    }
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(.qry)
    set resultset = statement.%Execute(dynd...)
    while resultset.%Next() {
        set line = {}
        set line.hash = resultset.Hash
        set line.namespace = resultset.NameSpace
        set line.hits = resultset.hits
        set line.time = resultset.time
        set line.query = ..GetQueryText(resultset.Hash)
        do result.%Push(line)
    }
    return result
}

ClassMethod GetTopHits(number As %Integer = 10, namespace As %String = "", fromDate As %Date = "", toDate As %Date = "")
{
    if fromDate = "" { set fromDate = +$h }
    if toDate = "" { set toDate = +$h }
    set result = []
    set qry = 3
    set qry(1) = "SELECT TOP ? sum(TotalHits) as hits,sum(TotalTime) as ""time"",Namespace,Hash"
    set qry(2) = "FROM BeVo_SQLMon_Data.BasicSQLStats"
    set qry(3) = "WHERE ""Date"">= ? and ""Date""<= ?"
    set dynd = 3
    set dynd(1) = number
    set dynd(2) = fromDate
    set dynd(3) = toDate
    if namespace '= "" {
        set qry = qry + 1
        set qry(qry) = "And namespace = ?"
        set dynd = dynd + 1
        set dynd(dynd) = namespace
    }    
    set qry = qry + 1
    set qry(qry) = "GROUP BY Namespace,Hash"
    set qry = qry + 1
    set qry(qry) = "ORDER BY hits desc"
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(.qry)
    set resultset = statement.%Execute(dynd...)
    while resultset.%Next() {
        set line = {}
        set line.hash = resultset.Hash
        set line.namespace = resultset.NameSpace
        set line.hits = resultset.hits
        set line.time = resultset.time
        set line.query = ..GetQueryText(resultset.Hash)
        do result.%Push(line)
    }
    return result
}

/// Get the statistics for a given query
/// <PARAMETER>queryHash: the hash identifying the query</PARAMETER>
/// <PARAMETER>namespace: optionaly the namespace the query was ran in</PARAMETER>
/// <PARAMETER>fromDate: optionaly a starting date for the stats</PARAMETER>
/// <PARAMETER>toDate: optionaly an end date for the stats </PARAMETER>
ClassMethod GetQueryStats(queryHash As %String, namespace As %String = "", fromDate As %Date = "", toDate As %Date = "") As %DynamicArray
{
    Set result = []
    set qry = 3
    set qry(1) = "SELECT ""date"",Hash,QueryText,Namespace,FromTime,ToTime,RoutineName,TotalTime,TotalHits,Variance"
    set qry(2) = "FROM BeVo_SQLMon_Data.BasicSQLStats"
    set qry(3) = "Where Hash = ?"
    set dynd = 1
    set dynd(1) = queryHash
    if fromDate '= "" {
        set qry = qry + 1
        set qry(qry) = "AND ""Date"" >= ?" 
        set dynd = dynd + 1
        set dynd(dynd) = fromDate
    }
    if toDate '= "" {
        set qry = qry + 1
        set qry(qry) = "AND ""Date"" <= ?" 
        set dynd = dynd + 1
        set dynd(dynd) = toDate
    }    
    set qry = qry + 1
    set qry(qry) = "ORDER BY ID asc"
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(.qry)
    set resultset = statement.%Execute(dynd...)
    while resultset.%Next() {
        set line = {}
        set line.hash = resultset.Hash
        set line.namespace = resultset.NameSpace
        set line.queryText = resultset.QueryText
        set line.date = resultset.Date
        set line.fromTime = resultset.FromTime
        set line.toTime = resultset.toTime
        set line.routine = resultset.RoutineName
        set line.hits = resultset.TotalHits
        set line.time = resultset.TotalTime
        set line.variance = resultset.Variance
        do result.%Push(line)
    }
    Return result
}

/// Get the query text from a hash
ClassMethod GetQueryText(hash As %String) As %String
{
    Set result = ""
    &sql(SELECT QueryText into:txt FROM BeVo_SQLMon_Data.BasicSQLStats where Hash = :hash)
    i 'SQLCODE,txt '= "" { set result = txt }
    Return result
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
