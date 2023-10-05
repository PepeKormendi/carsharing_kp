CLASS lhc_Car DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: platenumber_pattern TYPE string VALUE '^[A-Z]{2}-[A-Z]{2}-\d{3}$'.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Car RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Car RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Car RESULT result.

*    METHODS precheck_create FOR PRECHECK
*      IMPORTING entities FOR CREATE Car.
*
*    METHODS precheck_update FOR PRECHECK
*      IMPORTING entities FOR UPDATE Car.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Car~Resume.
    METHODS updateManStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Car~updateManStatus.

    METHODS validateManYear FOR VALIDATE ON SAVE
      IMPORTING keys FOR Car~validateManYear.

    METHODS validatePlateNumber FOR VALIDATE ON SAVE
      IMPORTING keys FOR Car~validatePlateNumber.

ENDCLASS.

CLASS lhc_Car IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Car
      FIELDS ( CarUUID )
      WITH CORRESPONDING #( keys )
    RESULT DATA(cars)
    FAILED failed.

    result = VALUE #( FOR car IN cars
                      ( %tky                   = car-%tky

                        %field-Img      = COND #( WHEN car-%is_draft  = if_abap_behv=>mk-on
                                                         THEN if_abap_behv=>fc-o-enabled
                                                         ELSE if_abap_behv=>fc-o-disabled )

                      ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

*  METHOD precheck_create.
*  ENDMETHOD.
*
*  METHOD precheck_update.
*  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

  METHOD updateManStatus.
  ENDMETHOD.

  METHOD validateManYear.
  ENDMETHOD.

  METHOD validatePlateNumber.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY Car
    FIELDS (  PlatNum )
    WITH CORRESPONDING #( keys )
  RESULT DATA(cars).

    LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>).
      IF strlen( <car>-PlatNum ) = 9.
        DATA(string) = match( val = <car>-PlatNum regex = platenumber_pattern occ = 1 ).
      ELSE.
      ENDIF.
      IF string NE <car>-PlatNum.
        APPEND VALUE #( %tky = <car>-%tky ) TO failed-car.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                         %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Invalid Platenumber ' )
        ) TO reported-car.
      ENDIF.
      CLEAR string.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
