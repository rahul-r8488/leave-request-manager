CLASS zcl_lr_load_data DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_lr_load_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zlr_ltype.
    INSERT zlr_ltype FROM TABLE @( VALUE #(
      ( leave_type = 'AL' description = 'Annual' )
      ( leave_type = 'SL' description = 'Sick' )
      ( leave_type = 'CL' description = 'Casual' ) ) ).
    out->write( |Leave types loaded: { sy-dbcnt }| ).
  ENDMETHOD.
ENDCLASS.