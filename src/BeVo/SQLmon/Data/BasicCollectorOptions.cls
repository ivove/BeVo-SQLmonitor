/// Class to allow access to the options for the BasicSQLStats collector
Class BeVo.SQLMon.Data.BasicCollectorOptions Extends %RegisteredObject
{

Property Enabled As %Boolean;

Property Interval As %Numeric;

Property Status As %String;

Method EnabledGet() As %Boolean
{
    set enabled = $GET(^BeVo.SQLmon.Options("Basic","Enabled"),0)
    return enabled
}

Method EnabledSet(value As %Boolean) As %Status
{
    if value '= i%Enabled{
        set ^BeVo.SQLmon.Options("Basic","Enabled") = value
        set calcTask = ..GetCalculateTask()
        set task = ..GetCollectorTask()
        i task '= $$$NULLOREF {
            set task.Suspended = ('value)
            do task.%Save()
        }
        i calcTask '= $$$NULLOREF, 'value {
            set calcTask.DailyIncrement = 60
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
            set task = ..GetCalculateTask()
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

Method StatusGet() As %String
{
    set status = "1"
    if ..Enabled {
        set calculateTask = ..GetCalculateTask()
        if calculateTask = $$$NULLOREF { set status = "0 Stats collection enabled but stats calculation task not found" } 
        else {
            if calculateTask.Suspended '= 0 { set status = "0 Stats collection enabled but stats caclulation task disabled" }
            elseif calculateTask.DailyIncrement '= ..Interval { set status = "0 The interval defined in the options differs from the interval of the stats calculation task" }
            else {
                set collectorTasks = ..GetCollectorTask()
                if collectorTasks = $$$NULLOREF { set status = "0 Stats collection enabled but stats collection task not found" }
                else {
                    if collectorTasks.Suspended '= 0 { set status = "0 Stats collection enabled but stats collector task disabled" }
                    elseif collectorTasks.RunAfterGUID '= calculateTask.JobGUID { set status = "0 The stats collector task in not running after the caclculte task, which should be the case" }
                }
            }
        }
    } else {
        set collectorTasks = ..GetCollectorTask()
        if collectorTasks '= $$$NULLOREF {
            if collectorTasks.Suspended = 0 {
                set status = "0 Stats collection disabled but collector task is running"
            }
        }
    }
    return status
}

Method StatusSet(value As %String) As %Status [ Private ]
{
    return $$$OK
}

/// get The collector tast
ClassMethod GetCollectorTask() As %SYS.Task [ Private ]
{
    set result = $$$NULLOREF
    set taskId = ##class(%SYS.Task).FindId("BeVo.SQLMon.Basic")
    i taskId '= "" {
        set result = ##class(%SYS.Task).%OpenId(taskId)
    }
    return result
}

/// get the task that calculates the statistics this is "Update SQL query statistics"
ClassMethod GetCalculateTask() As %SYS.Task
{
    set result = $$$NULLOREF
    set taskId = ##class(%SYS.Task).FindId("Update SQL query statistics")
    i taskId '= "" {
        set result = ##class(%SYS.Task).%OpenId(taskId)
    }
    return result
}

}
