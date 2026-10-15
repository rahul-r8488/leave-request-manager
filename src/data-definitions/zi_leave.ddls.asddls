@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request - Interface View'
define root view entity ZI_LEAVE
  as select from zlr_leave
{
  key leave_id              as LeaveId,
      employee_name         as EmployeeName,
      leave_type            as LeaveType,
      start_date            as StartDate,
      end_date              as EndDate,
      leave_days            as LeaveDays,
      reason                as Reason,
      status                as Status,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
