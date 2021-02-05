/// Class to gather the basic SQL performance stats and fill the BeVO.SQLmon.Data.BasicSQLStats class
/// /// This was inspired by the article "monitoring SQL query Performance" by David Loveluck (https://community.intersystems.com/post/apm-%E2%80%93-monitoring-sql-query-performance)
Class BeVo.SQLMon.API.BasicStatCollector Extends %RegisteredObject
{

ClassMethod DataCapture() As %Status
{
    // make sure not to collect sql stats for this process
    set statsCollection = $system.SQL.SetSQLStatsJob(-1)
    set currentNamespace = $ZNSPACE
    set date = +$HOROLOG
    set time = $PIECE($HOROLOG,",",2)
    // get all the namespaces on this system
    do ##class(%SYS.Namespace).ListAll(.namespaces)
    // clean the process-private variable holding the statistics
    kill ^||stats
    // loop over all namespaces to collect data
    set namespace = $ORDER(namespaces(""))
    while namespace '= "" {
        do ..DataCaptureNamespace(namespace,currentNamespace,date)
        set namespace = $ORDER(namespaces(namespace))
    }
    // process the gathered data and save it
    do ..PersistCapture(date,time)
    // reset the sql stats collection flag
    do $system.SQL.SetSQLStatsJob(statsCollection)
}

/// Capture the data for a given namespace
ClassMethod DataCaptureNamespace(namespace As %String, returnNamespace As %String, date As %Date) As %Status
{
    zn namespace
    try {
        set hash = $ORDER(^rINDEXSQL("sqlidx",1,""))
        while hash '= "" {
            set stats = $GET(^rINDEXSQL("sqlidx",1,hash,"stat",date))
            if stats '= "" {
                s ^||stats(namespace,hash,"stats")=stats
                // get the location this query is called from
                &SQL(SELECT  Location into :location FROM INFORMATION_SCHEMA.STATEMENT_LOCATIONS WHERE Statement=:hash)
                if SQLCODE '= 0 { set location = "" }
                set ^||stats(namespace,hash,"location")=location
                // get the sql query text 
                set ^||stats(namespace,hash,"queryText")=$GET(^rINDEXSQL("sqlidx",1,hash,"stat",date,1,1))
            }
            set hash = $ORDER(^rINDEXSQL("sqlidx",1,hash))
        }
    }
    catch ex {
        set ^||stats(namespace,"Error") = $ZERROR_"/"_$ECODE
    }
    zn returnNamespace
    Return $$$OK
}

/// Persist the captured data
ClassMethod PersistCapture(date As %Date, time As %Time) As %Status
{
    set namespace = $ORDER(^||stats(""))
    while namespace '= "" {
        set hash = $ORDER(^||stats(namespace,""))
        while hash '= "" {
            set stats = $GET(^||stats(namespace,hash,"stats"))
            if stats '= "" {
                set prevCounts = ##class(BeVo.SQLMon.Data.BasicSQLStats).GetTotals(hash,namespace,date)
                if ($LIST(stats,1) - prevCounts.totalHits) > 0 {
                    set oCapture = ##class(BeVo.SQLMon.Data.BasicSQLStats).%New()
                    set oCapture.Namespace = namespace
                    set oCapture.Date = date
                    set oCapture.ToTime = time
                    set oCapture.FromTime = ##class(BeVo.SQLMon.Data.BasicSQLStats).GetLastTime(hash,namespace,date) + 1
                    set oCapture.RoutineName = $GET(^||stats(namespace,hash,"location"))
                    set oCapture.QueryText = $GET(^||stats(namespace,hash,"queryText"))
                    set oCapture.Hash = hash
                    set oCapture.Variance = $LIST(stats,3)
                    set prevCounts = ##class(BeVo.SQLMon.Data.BasicSQLStats).GetTotals(hash,namespace,date)
                    set oCapture.TotalHits = $LIST(stats,1) - prevCounts.totalHits
                    set oCapture.TotalTime = $LIST(stats,2) - prevCounts.totalTime
                    do oCapture.%Save()
                }
            }
            set hash = $ORDER(^||stats(namespace,hash))
        }
        set namespace = $ORDER(^||stats(namespace))
    }
    Return $$$OK
}

}
