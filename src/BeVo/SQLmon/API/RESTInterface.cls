/// The rest interface for the SQLMon application
Class BeVo.SQLMon.API.RESTInterface Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/Options" Method="GET" Call="GetBasicOptions"/>
    <Route Url="/Options" Method="POST" Call="SetBasicOptions" />
    <Route Url="/Hits" Method="GET" Call="GetHits"/>
</Routes>
}

/// Return the basic options and the possible values for the options
ClassMethod GetBasicOptions() As %Status
{
    set result = {}
    set options = ##class(BeVo.SQLMon.Data.BasicCollectorOptions).%New()
    do result.%Set("enabled",options.Enabled,"boolean")
    set result.interval = []
    for i=5,10,15,30,60,720,1440 {
        set interval = {}
        set interval.interval = i
        do interval.%Set("selected",0,"boolean") 
        if options.Interval = i { do interval.%Set("selected",1,"boolean") }
        do result.interval.%Push(interval)
    }
    write result.%ToJSON()
    Return $$$OK
}

/// Set the options for the basic stats collector
/// Description
ClassMethod SetBasicOptions() As %Status
{
    if %request.Content {
        set obj = {}.%FromJSON(%request.Content)
        if obj.%IsDefined("enabled") && obj.%IsDefined("interval") {
            set options = ##class(BeVo.SQLMon.Data.BasicCollectorOptions).%New()
            set options.Enabled = obj.enabled
            set options.Interval = ..GetIntervalFromInput(obj)
            do ..GetBasicOptions()
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

ClassMethod GetIntervalFromInput(obj As %DynamicObject) As %Integer [ Private ]
{
    set interval = 60
    set intervalItter = obj.interval.%GetIterator()
    set key = "",cont = 1
    while intervalItter.%GetNext(.key,.value),cont {
        if value.selected {
            set cont = 0
            set interval = value.interval
        }
    }
    return interval
}

ClassMethod GetHits() As %Status
{
    set result = ##class(BeVo.SQLMon.Data.BasicSQLStats).GetStats()
    write result.%ToJSON()
    return $$$OK
}

}
