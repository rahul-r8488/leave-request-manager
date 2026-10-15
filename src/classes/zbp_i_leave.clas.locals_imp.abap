CLASS lhc_Leave DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Leave RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Leave RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Leave~setInitialStatus.

    METHODS calculateDays FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Leave~calculateDays.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Leave~validateDates.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION Leave~approve RESULT result.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION Leave~reject RESULT result.

ENDCLASS.

CLASS lhc_Leave IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    result = VALUE #( FOR l IN leaves
      ( %tky = l-%tky
        %action-approve = COND #( WHEN l-Status = 'P'
                                  THEN if_abap_behv=>fc-o-enabled
                                  ELSE if_abap_behv=>fc-o-disabled )
        %action-reject  = COND #( WHEN l-Status = 'P'
                                  THEN if_abap_behv=>fc-o-enabled
                                  ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    DELETE leaves WHERE Status IS NOT INITIAL.
    CHECK leaves IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave UPDATE FIELDS ( Status )
      WITH VALUE #( FOR l IN leaves ( %tky = l-%tky Status = 'P' ) ).
  ENDMETHOD.

  METHOD calculateDays.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    DATA updates TYPE TABLE FOR UPDATE zi_leave.

    LOOP AT leaves INTO DATA(lv)
         WHERE StartDate IS NOT INITIAL AND EndDate IS NOT INITIAL.
      IF lv-EndDate >= lv-StartDate.
        APPEND VALUE #( %tky      = lv-%tky
                        LeaveDays = lv-EndDate - lv-StartDate + 1 ) TO updates.
      ENDIF.
    ENDLOOP.

    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave UPDATE FIELDS ( LeaveDays )
      WITH updates.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    LOOP AT leaves INTO DATA(leave)
         WHERE StartDate IS NOT INITIAL AND EndDate IS NOT INITIAL.
      IF leave-EndDate < leave-StartDate.
        APPEND VALUE #( %tky = leave-%tky ) TO failed-leave.
        APPEND VALUE #( %tky = leave-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'End date cannot be before start date' )
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-leave.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approve.
    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'A' ) ).

    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    result = VALUE #( FOR l IN leaves ( %tky = l-%tky %param = l ) ).
  ENDMETHOD.

  METHOD reject.
    MODIFY ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'R' ) ).

    READ ENTITIES OF zi_leave IN LOCAL MODE
      ENTITY Leave ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(leaves).

    result = VALUE #( FOR l IN leaves ( %tky = l-%tky %param = l ) ).
  ENDMETHOD.

ENDCLASS.