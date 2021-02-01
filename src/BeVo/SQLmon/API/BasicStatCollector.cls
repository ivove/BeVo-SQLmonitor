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
                &SQL(SELECT  Statement INTO :statement FROM INFORMATION_SCHEMA.STATEMENTS WHERE Hash=:hash)
                if SQLCODE '= 0 { set statement = "" }
                set ^||stats(namespace,hash,"queryText")=statement
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

}
