/// The rest interface for the SQLMon application
Class BeVo.SQLMon.API.RESTInterface Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
      <Route Url="/BasicOptions" Method="GET" Call="GetBasicOptions"/>
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

}
