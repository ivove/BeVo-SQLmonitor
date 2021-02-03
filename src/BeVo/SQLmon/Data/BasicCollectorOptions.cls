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
    if value '= i%Enabled{
        set ^BeVo.SQLmon.Options("Basic","Enabled") = value
        set task = ..GetCollectorTask()
        i task '= $$$NULLOREF {
            set task.Suspended = ('value)
            do task.%Save()
        }
    }
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
        if value '= i%Interval {
            set ^BeVo.SQLmon.Options("Basic","Interval") = value
            set task = ..GetCollectorTask()
            i task '= $$$NULLOREF {
                set task.DailyIncrement = value
                do task.%Save()
            }
        }
    } else {
        set done = $$$ERROR(52)
    }
    return done
}

/// get The collector tast
ClassMethod GetCollectorTask() As %SYS.Task [ Private ]
{
    set result = ""
    set taskId = ##class(%SYS.Task).FindId("BeVo.SQLMon.Basic")
    i taskId '= "" {
        set result = ##class(%SYS.Task).%OpenId(taskId)
    }
    return result
}

}
