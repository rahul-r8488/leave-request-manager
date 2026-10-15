@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request - Projection'
@Metadata.allowExtensions: true
define root view entity ZC_LEAVE
  provider contract transactional_query
  as projection on ZI_LEAVE
{
  key LeaveId,
      @EndUserText.label: 'Employee Name'
      EmployeeName,
      @EndUserText.label: 'Leave Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_LTYPE_VH', element: 'LeaveType' } }]
      LeaveType,
      @EndUserText.label: 'Start Date'
      StartDate,
      @EndUserText.label: 'End Date'
      EndDate,
      @EndUserText.label: 'Leave Days'
      LeaveDays,
      @EndUserText.label: 'Reason'
      Reason,
      @EndUserText.label: 'Status'
      Status,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
