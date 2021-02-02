/// Class to allow access to the options for the BasicSQLStats collector
Class BeVo.SQLMon.Data.BasicCollectorOptions Extends %RegisteredObject
{

Property Enabled As %Boolean;

Property Interval As %Numeric;

Method EnabledGet() As %Boolean
{
    set enabled = $GET(^BeVo.SQLmon.Options("Basic","Enabled"),0)
    return enabled
}

Method EnabledSet(value As %Boolean) As %Status
{
    set ^BeVo.SQLmon.Options("Basic","Enabled") = value
    return $$$OK
}

Method IntervalGet() As %Numeric
{
    set interval = $GET(^BeVo.SQLmon.Options("Basic","Interval"),60)
    return interval
}

Method IntervalSet(value As %Numeric) As %Status
{
    set done = $$$OK
    if "/5/10/15/30/60/720/1440/"[("/"_value_"/") {
        // only if the interval is acceptable
        set ^BeVo.SQLmon.Options("Basic","Interval") = value
    } else {
        set done = $$$ERROR(52)
    }
    return done
}

}
