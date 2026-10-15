CLASS lhc_LeaveRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR LeaveRequest RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      keys FOR LeaveRequest~setInitialStatus.

    METHODS calculateDays FOR DETERMINE ON MODIFY
      keys FOR LeaveRequest~calculateDays.

    METHODS validateDates FOR VALIDATE ON SAVE
      keys FOR LeaveRequest~validateDates.

    METHODS approve FOR MODIFY
      keys FOR ACTION LeaveRequest~approve RESULT result.

    METHODS reject FOR MODIFY
      keys FOR ACTION LeaveRequest~reject RESULT result.

ENDCLASS.

CLASS lhc_LeaveRequest IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    DELETE requests WHERE Status IS NOT INITIAL.
    CHECK requests IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest UPDATE FIELDS ( Status )
      WITH VALUE #( FOR r IN requests ( %tky = r-%tky Status = 'P' ) ).
  ENDMETHOD.

  METHOD calculateDays.
    " Read StartDate and EndDate for all changed records
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    " Build update table via LOOP to avoid the WHERE-inside-FOR activation issue
    DATA lt_update TYPE TABLE FOR UPDATE zi_leave\\LeaveRequest.
    LOOP AT requests INTO DATA(req).
      CHECK req-StartDate IS NOT INITIAL AND req-EndDate IS NOT INITIAL.
      CHECK req-EndDate >= req-StartDate.
      DATA(lv_days) = req-EndDate - req-StartDate + 1.
      APPEND VALUE #( %tky      = req-%tky
                      LeaveDays = lv_days ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest UPDATE FIELDS ( LeaveDays )
      WITH lt_update.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    LOOP AT requests INTO DATA(req).
      CHECK req-StartDate IS NOT INITIAL AND req-EndDate IS NOT INITIAL.
      IF req-EndDate < req-StartDate.
        APPEND VALUE #( %tky = req-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #( %tky = req-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'End date must not be before start date' )
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-LeaveRequest.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approve.
    " Only act on requests that are still Pending
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    DATA lt_update TYPE TABLE FOR UPDATE zi_leave\\LeaveRequest.
    LOOP AT requests INTO DATA(req) WHERE Status = 'P'.
      APPEND VALUE #( %tky = req-%tky Status = 'A' ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest UPDATE FIELDS ( Status )
      WITH lt_update.

    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated).
    result = VALUE #( FOR r IN updated ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD reject.
    " Only act on requests that are still Pending
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    DATA lt_update TYPE TABLE FOR UPDATE zi_leave\\LeaveRequest.
    LOOP AT requests INTO DATA(req) WHERE Status = 'P'.
      APPEND VALUE #( %tky = req-%tky Status = 'R' ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest UPDATE FIELDS ( Status )
      WITH lt_update.

    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY LeaveRequest ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated).
    result = VALUE #( FOR r IN updated ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.
