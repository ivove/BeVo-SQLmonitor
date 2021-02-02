Class BeVo.SQLMon.API.Installer Extends %RegisteredObject
{

ClassMethod Install()
{
    set x = $NAMESPACE
    zw x
    ZN "%SYS"
    do ..CreateRole()
    do ..AddRole()
    do ..CreateRestAPI()
    zn x
    do ..CreateTask()
}

ClassMethod CreateRestAPI()
{
    /* unauthenticade */

    set name = "/BeVo/SQLMon"
    if '##class(Security.Applications).Exists(name) {
        set cspProperties("AutheEnabled") = 64
        
        set cspProperties("NameSpace") = "USER"
        set cspProperties("IsNameSpaceDefault") = 0
        set cspProperties("DispatchClass") = "BeVo.SQLMon.API.RESTInterface"
        
        set tSC = ##class(Security.Applications).Create(name, .cspProperties)
    }
}

ClassMethod CreateRole()
{
    set name = "BeVo.SQLMon"
    if '##class(Security.Roles).Exists(name) {
        set description = "Role for BeVo.SQLMon application"
        set recources = "%DB_USER:RW,%Service_Webgateway:U"
        set tSC = ##class(Security.Roles).Create(name,description,recources)
    }
}

ClassMethod AddRole()
{
    set tSC = ##class(Security.Users).AddRoles("UnknownUser","BeVo.SQLMon",0)
}

ClassMethod CreateTask()
{
    set taskId = ##class(%SYS.Task).FindId("BeVo.SQLMon.Basic")
    if taskId = "" {
        // only create the task if it does not already exist
        set task = ##class(%SYS.Task).%New()
        set task.Name = "BeVo.SQLMon.Basic"
        set task.DailyFrequency = 1 // set as once a day
        set task.DailyFrequencyTime = 0
        set task.DailyIncrement = 60 // run every 60 minutes
        set task.DailyStartTime = 0 // start at midnight
        set task.NameSpace = $NAMESPACE
        set task.Description = "Basic data collector for the BeVo.SQLMon app"
        set task.RescheduleOnStart = 1 // reschedule on system reboot
        set task.RunAsUser = "_SYSTEM"
        set task.Suspended = 1 // suspend the task so it will not run
        set task.TaskClass = "BeVo.SQLMon.API.BasicCollectorTaks" // set the taskdefinition
        set task.Type = 2
        set task.TimePeriod = 0
        set task.TimePeriodEvery = 1
        set task.TimePeriodDay = ""
        do task.%Save()
    }
}

}
