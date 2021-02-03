Class BeVo.SQLMon.Demo.Demo Extends %RegisteredObject
{

/// Method to demo sql stats. this method will periodicaly run several queries. Just let this run in a terminal session
ClassMethod Demo() As %Status
{
    while 1 {
        set choice = $RANDOM(3)
        if choice = 1 {
            do ..Embedded()
        } elseif choice = 2 {
            d ..ClassQuery()
        } elseif choice = 0 {
            d ..DynamicQuery()
        }
        set halt = ($RANDOM(14) + 1)
        w !,"waiting: ",halt,!
        h halt
    }
}

/// execute an embedded query
ClassMethod Embedded() As %Status
{
    set choice = $RANDOM(5)
    if choice = 0 {
        &SQL(DECLARE vendor CURSOR FOR SELECT ID into:id FROM SAMPLE.Vendor)
        &SQL(OPEN vendor)
        while 'SQLCODE {
            &SQL(FETCH vendor)
        }
        &SQL(CLOSE vendor)
    } elseif choice = 1 {
        &SQL(DECLARE vendor2 CURSOR FOR SELECT ID into:id FROM SAMPLE.Vendor where DiscRate > 50)
        &SQL(OPEN vendor2)
        while 'SQLCODE {
            &SQL(FETCH vendor2)
        }
        &SQL(CLOSE vendor2)
    } elseif choice = 2 {
        &SQL(DECLARE employee CURSOR FOR SELECT ID into:id FROM SAMPLE.employee)
        &SQL(OPEN employee)
        while 'SQLCODE {
            &SQL(FETCH employee)
        }
        &SQL(CLOSE employee)
    } elseif choice = 3 {
        &SQL(DECLARE employee2 CURSOR FOR SELECT ID into:id FROM SAMPLE.employee where salary < 50000)
        &SQL(OPEN employee2)
        while 'SQLCODE {
            &SQL(FETCH employee2)
        }
        &SQL(CLOSE employee2)
    } elseif choice = 4 {
        &SQL(DECLARE company CURSOR FOR SELECT ID into:id FROM SAMPLE.Company)
        &SQL(OPEN company)
        while 'SQLCODE {
            &SQL(FETCH company)
        }
        &SQL(CLOSE company)
    }
}

/// execute a classquery
ClassMethod ClassQuery() As %Status
{
    SET statemt=##class(%SQL.Statement).%New()
  SET cqStatus=statemt.%PrepareClassQuery("Sample.Person","ByName")
    IF cqStatus'=1 {WRITE "%PrepareClassQuery failed:" DO $System.Status.DisplayError(cqStatus) QUIT}
  SET rset=statemt.%Execute("L")
  DO rset.%Display()
}

/// execute some dynamic sql
ClassMethod DynamicQuery() As %Status
{
    set choice = $RANDOM(5)
    if choice = 0 {
        SET myquery = "SELECT TOP 5 Name,DOB FROM Sample.Person"
        SET tStatement = ##class(%SQL.Statement).%New()
        SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
        SET rset = tStatement.%Execute()
        DO rset.%Display()
    } elseif choice = 1 {
        SET myquery = "SELECT Name,DOB FROM Sample.Person"
        SET tStatement = ##class(%SQL.Statement).%New()
        SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
        SET rset = tStatement.%Execute()
        DO rset.%Display()
    } elseif choice = 2 {
        SET myquery = "SELECT Name,Mission,TaxId FROM Sample.Company"
        SET tStatement = ##class(%SQL.Statement).%New()
        SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
        SET rset = tStatement.%Execute()
        DO rset.%Display()
    } elseif choice = 3 {
        SET myquery = "SELECT ID,Name FROM SAMPLE.Vendor where DiscRate < 5"
        SET tStatement = ##class(%SQL.Statement).%New()
        SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
        SET rset = tStatement.%Execute()
        DO rset.%Display()
    } elseif choice = 4 {
        SET myquery = "SELECT ID Name,Title,Salary FROM SAMPLE.employee where salary > 75000"
        SET tStatement = ##class(%SQL.Statement).%New()
        SET qStatus = tStatement.%Prepare(myquery)
        IF qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
        SET rset = tStatement.%Execute()
        DO rset.%Display()
    }
}

}
