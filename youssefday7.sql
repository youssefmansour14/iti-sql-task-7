---day7 
---q1
use ITI
go
CREATE PROCEDURE dbo.GetStudentsPerDepartment
AS
BEGIN
    SELECT d.[Dept_Name], COUNT(*) AS NumberOfStudents
    FROM [dbo].[Student]s join[dbo].[Department]d on d.[Dept_Id]=s.[Dept_Id]
    GROUP BY d.[Dept_Name]
END
EXEC dbo.GetStudentsPerDepartment
go
---q2
---2.Create a stored procedure that will check for the number of 
--employees in the project p1 if they are more than 3 
--print message to the user “'The number of employees in the project p1 is 3 or more'”
--if they are less display a message to the user
--“'The following employees work for the project p1'”
--in addition to the first name and last name of each one. [Company DB] 
use MyCompany
go
CREATE PROCEDURE dbo.CheckEmployeesInProjectP1
AS
BEGIN
    DECLARE @NumEmployees INT
    SELECT @NumEmployees = COUNT(*) FROM [dbo].[Works_for] w join [dbo].[Project] p on p.[Pnumber]= w.[Pno]
		 WHERE p.Pname = 'p1'
    IF @NumEmployees >= 3
        PRINT 'The number of employees in the project p1 is 3 or more'
    ELSE
    BEGIN
        PRINT 'The following employees work for the project p1:'
        SELECT E.FName, E.Lname FROM Employee E WHERE E.SSN  IN 
		(SELECT w.[ESSn] FROM [dbo].[Works_for] w join [dbo].[Project] p on p.[Pnumber]= w.[Pno]
		 WHERE p.Pname = 'p1')
    END
END
EXEC dbo.CheckEmployeesInProjectP1
go

--q3
--3.	Create a stored procedure that will be used in case there is an old
--employee has left the project and a new one become 
--instead of him. The procedure should take 3 parameters (old Emp. number,
--new Emp. number and the project number)
--and it will be used to update works_on table. [Company DB]
CREATE or alter  PROCEDURE dbo.UpdateWorksOnTable
    @OldEmpNumber INT,
    @NewEmpNumber INT,
    @ProjectNumber INT
AS
BEGIN
    UPDATE [dbo].[Works_for]
    SET ESSn = @NewEmpNumber
    WHERE ESSn = @OldEmpNumber AND Pno = @ProjectNumber
END
EXEC dbo.UpdateWorksOnTable @OldEmpNumber = 123, @NewEmpNumber = 456, @ProjectNumber = 'p1'
go

---q4
--4. Create a trigger that prevents the insertion 
--Process for Employee table in March [Company DB].
CREATE TRIGGER PreventInsertionInMarch
ON Employee
FOR INSERT
AS
BEGIN
    IF MONTH(GETDATE()) = 3
    BEGIN
        RAISERROR('Insertion is not allowed in March', 16, 1)
        ROLLBACK TRANSACTION
    END
END
go

--q5
--5. Create a trigger to prevent anyone from inserting 
--anew record in the Department table [ITI DB]
--“Print a message for user to tell him that
-- he can’t insert a new record in that table”
go
CREATE TRIGGER PreventInsertionInDepartment
ON [dbo].[Dependent]
INSTEAD OF INSERT
AS
BEGIN
    PRINT 'You cannot insert a new record in the Department table'
END
go
--q6
--6. Create a trigger on student table after insert to add Row in 
--Student Audit table (Server User Name, Date, Note)
--where note will be “[username] Insert New Row with ID=[ID Value] in table Student”
use ITI
go
CREATE TRIGGER AddRowToStudentAudit
ON [dbo].[Student]
AFTER INSERT
AS
BEGIN
    DECLARE @UserName NVARCHAR(128)
    SET @UserName = SUSER_SNAME()
    
    INSERT INTO StudentAudit (ServerUserName, DateOf, Note)
    SELECT @UserName, GETDATE(), '[' + @UserName + '] Insert New Row with ID=' 
	+ CAST([St_Id] AS NVARCHAR(50)) + ' in table Student'
    FROM inserted
END
go
--q7
--
go
CREATE TRIGGER DeleteRowToStudentAudit
ON Student
AFTER DELETE
AS
BEGIN
    DECLARE @UserName NVARCHAR(128)
    SET @UserName = SUSER_SNAME()
    
    INSERT INTO StudentAudit (ServerUserName, DateOf, Note)
    SELECT @UserName, GETDATE(), '[' + @UserName + '] deleted Row with ID=' + CAST([St_Id] AS NVARCHAR(50))
    FROM deleted
END

--bouns
--q8
BEGIN TRANSACTION
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (17, 'John', 20)
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (18, 'Jane', 22)
SAVE TRANSACTION SavePoint1
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (19, 'Bob', 25)
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (20, 'Alice', 23)
SAVE TRANSACTION SavePoint2
ROLLBACK TRANSACTION SavePoint1
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (21, 'Tom', 21)
INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (22, 'Sara', 24)
COMMIT TRANSACTION
go



--q9
BEGIN TRY
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (17, 'John', 20)
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (18, 'Jane', 22)
    SAVE TRANSACTION SavePoint1
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (19, 'Bob', 25)
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (20, 'Alice', 23)
    SAVE TRANSACTION SavePoint2
    ROLLBACK TRANSACTION SavePoint1
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (21, 'Tom', 21)
    INSERT INTO Student (St_Id, St_Fname, St_Age) VALUES (22, 'Sara', 24)

END TRY
BEGIN CATCH
    DECLARE @ErrorMsg NVARCHAR(4000);
    DECLARE @ErrSeverity INT;
    DECLARE @ErrState INT;
    SELECT @ErrorMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY(), @ErrState = ERROR_STATE();
    RAISERROR (@ErrorMsg, @ErrSeverity, @ErrState);
END CATCH;


