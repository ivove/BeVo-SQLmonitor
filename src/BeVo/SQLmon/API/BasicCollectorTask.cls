/// A class to hold the definition for the iris taskprocessor.
Class BeVo.SQLMon.API.BasicCollectorTaks Extends %SYS.Task.Definition
{

Parameter TaskName = "Collect basic SQL Statistics";

Method OnTask() As %Status
{
    set result = $$$OK
    TRY {
        do ##class(BeVo.SQLMon.API.BasicStatCollector).DataCapture()
    }
    CATCH exp {
        set result = $SYSTEM.Status.Error("Error in Collect basic SQL Statistics Task")
    }
    return result
}

}
