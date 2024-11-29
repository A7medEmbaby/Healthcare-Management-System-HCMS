CREATE DATABASE HCMS
GO
USE [HCMS]
GO
/****** Object:  DatabaseRole [StaffRole]    Script Date: 11/29/2024 3:39:23 PM ******/
CREATE ROLE [StaffRole]
GO
/****** Object:  Table [dbo].[Appointments]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appointments](
	[AppointmentID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[AppointmentDate] [date] NOT NULL,
	[AppointmentTime] [time](7) NOT NULL,
	[Status] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AppointmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_DoctorAppointmentSummary]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_DoctorAppointmentSummary]
WITH SCHEMABINDING AS
SELECT DoctorID, COUNT_BIG(*) AS TotalAppointments
FROM dbo.Appointments
GROUP BY DoctorID;
GO
/****** Object:  Table [dbo].[Patients]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patients](
	[PatientID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Gender] [char](1) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[ContactInfo] [nvarchar](255) NULL,
	[MedicalHistory] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[PatientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Billing]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Billing](
	[BillID] [int] IDENTITY(1,1) NOT NULL,
	[AppointmentID] [int] NOT NULL,
	[PatientID] [int] NOT NULL,
	[TotalAmount] [decimal](10, 2) NOT NULL,
	[PaidAmount] [decimal](10, 2) NULL,
	[PaymentStatus] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_PatientsBills]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_PatientsBills]
as
	select 
		P.PatientID,
		P.FirstName,
		P.LastName,
		sum(B.TotalAmount) as PatientsBills
	from Patients P
	join Billing B on P.PatientID = B.PatientID
	group by P.PatientID, P.FirstName, P.LastName;
GO
/****** Object:  View [dbo].[vw_PatientsWithoutAppointments]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_PatientsWithoutAppointments] AS
SELECT 
    Patients.PatientID, 
    CONCAT(Patients.FirstName, ' ', Patients.LastName) AS PatientName
FROM 
    Patients
LEFT JOIN 
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE 
    Appointments.AppointmentID IS NULL
    OR DATEDIFF(YEAR, Appointments.AppointmentDate, GETDATE()) > 1;
GO
/****** Object:  View [dbo].[BillingStatistics]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[BillingStatistics] AS
SELECT 
    DATEPART(MONTH, a.AppointmentDate) as Month,
    DATEPART(YEAR, a.AppointmentDate) as Year,
    COUNT(*) as TotalBills,
    SUM(b.TotalAmount) as TotalBilled,
    SUM(b.PaidAmount) as TotalCollected,
    SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN 1 ELSE 0 END) as PaidBills,
    SUM(CASE WHEN b.PaymentStatus = 'Partially Paid' THEN 1 ELSE 0 END) as PartiallyPaidBills,
    SUM(CASE WHEN b.PaymentStatus = 'Pending' THEN 1 ELSE 0 END) as PendingBills
FROM Billing b
JOIN Appointments a ON b.AppointmentID = a.AppointmentID
GROUP BY DATEPART(MONTH, a.AppointmentDate), DATEPART(YEAR, a.AppointmentDate);
GO
/****** Object:  Table [dbo].[AppointmentLogs]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppointmentLogs](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](20) NOT NULL,
	[AppointmentID] [int] NOT NULL,
	[ChangeDate] [datetime] NOT NULL,
	[LogDetails] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[DepartmentID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](200) NOT NULL,
	[Location] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Doctors]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctors](
	[DoctorID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Specialty] [nvarchar](200) NOT NULL,
	[ContactInfo] [nvarchar](255) NULL,
	[DepartmentID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DoctorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmergencyContacts]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmergencyContacts](
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Relationship] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Insurance]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Insurance](
	[InsuranceID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[InsuranceProvider] [nvarchar](200) NOT NULL,
	[PolicyNumber] [nvarchar](100) NOT NULL,
	[CoverageDetails] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[InsuranceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PolicyNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabTests]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabTests](
	[LabTestID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[TestName] [nvarchar](200) NOT NULL,
	[TestDate] [date] NOT NULL,
	[Results] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[LabTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicalRecords]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalRecords](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[RecordDate] [date] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Medications]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medications](
	[MedicationID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Cost] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MedicationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prescriptions]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prescriptions](
	[PrescriptionID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[MedicationID] [int] NOT NULL,
	[DateIssued] [date] NOT NULL,
	[Dosage] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PrescriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rooms]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rooms](
	[RoomID] [int] IDENTITY(1,1) NOT NULL,
	[RoomNumber] [nvarchar](50) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[RoomType] [varchar](50) NOT NULL,
	[AvailabilityStatus] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoomID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Schedules]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schedules](
	[ScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[DoctorID] [int] NOT NULL,
	[DayOfWeek] [varchar](20) NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[StaffID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Role] [varchar](50) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[ContactInfo] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Visits]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visits](
	[VisitID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[VisitDate] [date] NOT NULL,
	[Purpose] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[VisitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppointmentLogs] ADD  DEFAULT (getdate()) FOR [ChangeDate]
GO
ALTER TABLE [dbo].[AppointmentLogs]  WITH CHECK ADD  CONSTRAINT [FK_AppointmentLogs_Appointments] FOREIGN KEY([AppointmentID])
REFERENCES [dbo].[Appointments] ([AppointmentID])
GO
ALTER TABLE [dbo].[AppointmentLogs] CHECK CONSTRAINT [FK_AppointmentLogs_Appointments]
GO
ALTER TABLE [dbo].[Appointments]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Appointments]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Billing]  WITH NOCHECK ADD FOREIGN KEY([AppointmentID])
REFERENCES [dbo].[Appointments] ([AppointmentID])
GO
ALTER TABLE [dbo].[Billing]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
GO
ALTER TABLE [dbo].[Doctors]  WITH NOCHECK ADD FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Departments] ([DepartmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmergencyContacts]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Insurance]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LabTests]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LabTests]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MedicalRecords]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MedicalRecords]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescriptions]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescriptions]  WITH NOCHECK ADD FOREIGN KEY([MedicationID])
REFERENCES [dbo].[Medications] ([MedicationID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescriptions]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Rooms]  WITH NOCHECK ADD FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Departments] ([DepartmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Schedules]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Staff]  WITH NOCHECK ADD FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Departments] ([DepartmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Visits]  WITH NOCHECK ADD FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctors] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Visits]  WITH NOCHECK ADD FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patients] ([PatientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AppointmentLogs]  WITH CHECK ADD CHECK  (([Action]='DELETE' OR [Action]='UPDATE' OR [Action]='INSERT'))
GO
ALTER TABLE [dbo].[Appointments]  WITH NOCHECK ADD CHECK  (([Status]='Cancelled' OR [Status]='Completed' OR [Status]='Scheduled'))
GO
ALTER TABLE [dbo].[Billing]  WITH NOCHECK ADD CHECK  (([PaymentStatus]='Partially Paid' OR [PaymentStatus]='Paid' OR [PaymentStatus]='Pending'))
GO
ALTER TABLE [dbo].[Patients]  WITH NOCHECK ADD CHECK  (([Gender]='F' OR [Gender]='M'))
GO
ALTER TABLE [dbo].[Rooms]  WITH NOCHECK ADD CHECK  (([AvailabilityStatus]='Occupied' OR [AvailabilityStatus]='Available'))
GO
ALTER TABLE [dbo].[Rooms]  WITH NOCHECK ADD CHECK  (([RoomType]='Private Room' OR [RoomType]='General Ward' OR [RoomType]='ICU'))
GO
ALTER TABLE [dbo].[Schedules]  WITH NOCHECK ADD CHECK  (([DayOfWeek]='Sunday' OR [DayOfWeek]='Saturday' OR [DayOfWeek]='Friday' OR [DayOfWeek]='Thursday' OR [DayOfWeek]='Wednesday' OR [DayOfWeek]='Tuesday' OR [DayOfWeek]='Monday'))
GO
ALTER TABLE [dbo].[Staff]  WITH NOCHECK ADD CHECK  (([Role]='Receptionist' OR [Role]='Nurse'))
GO
/****** Object:  StoredProcedure [dbo].[AddPatient]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddPatient]
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Gender char(1),
	@DateOfBirth date,
	@ContactInfo nvarchar(100),
	@MecicalHistory nvarchar(MAX)
as
begin
	insert into Patients(FirstName, LastName, Gender, DateOfBirth, ContactInfo, MedicalHistory)
	values(
	@FirstName,
	@LastName,
	@Gender,
	@DateOfBirth,
	@ContactInfo,
	@MecicalHistory	
	);
end
GO
/****** Object:  StoredProcedure [dbo].[AssignPatientToRoom]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AssignPatientToRoom]
    @PatientID INT,
    @DepartmentID INT
AS
BEGIN
    DECLARE @RoomID INT;

    -- Find an available room in the given department
    SELECT TOP 1 @RoomID = RoomID
    FROM Rooms
    WHERE DepartmentID = @DepartmentID AND AvailabilityStatus = 'Available';

    IF @RoomID IS NOT NULL
    BEGIN
        UPDATE Rooms
        SET AvailabilityStatus = 'Occupied'
        WHERE RoomID = @RoomID;

        INSERT INTO Visits (PatientID, DoctorID, VisitDate, Purpose)
        VALUES (@PatientID, NULL, GETDATE(), 'Room Assigned');
    END
    ELSE
    BEGIN
        PRINT 'No available room found in the specified department.';
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[CalculateDoctorRevenue]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CalculateDoctorRevenue]
    @DoctorID INT,
    @StartDate DATE,
    @EndDate DATE,
    @TotalRevenue MONEY OUTPUT
AS
BEGIN
    SELECT @TotalRevenue = SUM(b.TotalAmount)
    FROM Appointments a
    JOIN Billing b ON a.AppointmentID = b.AppointmentID
    WHERE a.DoctorID = @DoctorID
      AND a.AppointmentDate BETWEEN @StartDate AND @EndDate;
END;
GO
/****** Object:  StoredProcedure [dbo].[ListAppointmentsByPatient]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListAppointmentsByPatient]
    @PatientID INT
AS
BEGIN
    SELECT 
		a.AppointmentID, 
		a.AppointmentDate, 
		a.AppointmentTime, 
		d.FirstName AS DoctorFirstName, 
		d.LastName AS 
		DoctorLastName, 
		a.Status
    FROM Appointments a
    JOIN Doctors d ON a.DoctorID = d.DoctorID
    WHERE a.PatientID = @PatientID;
END;

GO
/****** Object:  StoredProcedure [dbo].[UpdateDoctorContactInformation]    Script Date: 11/29/2024 3:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UpdateDoctorContactInformation]
	@DoctorID INT,
	@NewContactInfo nvarchar(100)
as
begin
	update Doctors
	set ContactInfo = @NewContactInfo
	where DoctorID = @DoctorID;
end
GO
