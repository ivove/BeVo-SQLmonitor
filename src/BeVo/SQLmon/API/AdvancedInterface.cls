/// The Advanced rest interface for the SQLMon application
Class BeVo.SQLMon.API.AdvancedInterface Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/Options" Method="GET" Call="GetOptions"/>
    <Route Url="/Options" Method="POST" Call="SetOptions" />
</Routes>
}

/// Get the Advanced options
ClassMethod GetOptions() As %Status
{
    set options = {}
    set SQLStatsFlag = ##class(%SYS.PTools.StatsSQL).GetSQLStatsFlag("")
    do options.%Set("enabled",($PIECE(SQLStatsFlag,":",1) > 0),"boolean")
    write options.%ToJSON()
    Return $$$OK
}

/// Set the advanced options
ClassMethod SetOptions() As %Status
{
    if %request.Content {
        set obj = {}.%FromJSON(%request.Content)
        if obj.%IsDefined("enabled") {
            if obj.enabled {
                do ##class(%SYS.PTools.StatsSQL).SetSQLStats(3)
            } else {
                do ##class(%SYS.PTools.StatsSQL).SetSQLStats(0)
            }
            do ..GetOptions()
        } else {
            set %response.Status = ..#HTTP400BADREQUEST
            set error = {"errormessage" : "Missing enabled and/or interval fields"}
            write error.%ToJSON()
        }
    }
    else {
        set %response.Status = ..#HTTP400BADREQUEST
        set error = {"errormessage" : "No content found in request"}
        write error.%ToJSON()
    }
    Return $$$OK
}

}
