@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Type Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_LTYPE_VH
  as select from zlr_ltype
{
      @ObjectModel.text.element: [ 'Description' ]
  key leave_type  as LeaveType,
      description as Description
}
