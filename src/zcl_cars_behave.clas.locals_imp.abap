CLASS lsc_zkp_i_cars DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.



ENDCLASS.

CLASS lsc_zkp_i_cars IMPLEMENTATION.

  METHOD save_modified.
    DATA: cars TYPE STANDARD TABLE OF zkp_cars.
    DATA: bookings TYPE STANDARD TABLE OF zkp_car_bookings.
    DATA ls_in TYPE zautos_invoice_input.
    IF create IS NOT INITIAL.
      cars = CORRESPONDING #( create-car MAPPING FROM ENTITY ).
      bookings = CORRESPONDING #(  create-booking MAPPING FROM ENTITY ).
      DATA(car) = VALUE #( cars[ 1 ] OPTIONAL ).
      LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
        IF car IS INITIAL.
          SELECT SINGLE * FROM zkp_cars INTO CORRESPONDING FIELDS OF car WHERE car_uuid = <booking>-parent_uuid.
        ENDIF.
        DATA(input) = CORRESPONDING zautos_invoice_input( <booking>
                                  MAPPING bookingid = booking_uuid
                                           bookingfrom = booked_from
                                           bookingto = booked_to
                                           price = book_price
                                           currency = currency_code ).

*        input-partnerid =  'A71D59F438A71EEE9AA4F53C12DB471F'.
        input-partnerid =  <booking>-customer_uuid.
        input-platenumber = CONV #( car-platenum ).
        input-brand = CONV #( car-brand ).
        input-model = CONV #( car-model ).
        DATA(lc_invoice) = NEW zcl_csz_invoice_helper( is_booking = input ).
        lc_invoice->main( ).
      ENDLOOP.
    ENDIF.
    IF update IS NOT INITIAL.
      cars = CORRESPONDING #( update-car MAPPING FROM ENTITY ).
            cars = CORRESPONDING #( create-car MAPPING FROM ENTITY ).
      bookings = CORRESPONDING #(  create-booking MAPPING FROM ENTITY ).
      car = VALUE #( cars[ 1 ] OPTIONAL ).
      LOOP AT bookings ASSIGNING <booking>.
        IF car IS INITIAL.
          SELECT SINGLE * FROM zkp_cars INTO CORRESPONDING FIELDS OF car WHERE car_uuid = <booking>-parent_uuid.
        ENDIF.
        input = CORRESPONDING zautos_invoice_input( <booking>
                                  MAPPING bookingid = booking_uuid
                                           bookingfrom = booked_from
                                           bookingto = booked_to
                                           price = book_price
                                           currency = currency_code ).

*        input-partnerid =  'A71D59F438A71EEE9AA4F53C12DB471F'.
        input-partnerid =  <booking>-customer_uuid.
        input-platenumber = CONV #( car-platenum ).
        input-brand = CONV #( car-brand ).
        input-model = CONV #( car-model ).
        lc_invoice = NEW zcl_csz_invoice_helper( is_booking = input ).
        lc_invoice->main( ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


ENDCLASS.

CLASS lhc_car DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: platenumber_pattern TYPE string VALUE '^[A-Z]{2}-[A-Z]{2}-\d{3}$'.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR car RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR car RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR car RESULT result.

*    METHODS precheck_create FOR PRECHECK
*      IMPORTING entities FOR CREATE Car.
*
*    METHODS precheck_update FOR PRECHECK
*      IMPORTING entities FOR UPDATE Car.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION car~resume.
    METHODS updatemanstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR car~updatemanstatus.

    METHODS validatemanyear FOR VALIDATE ON SAVE
      IMPORTING keys FOR car~validatemanyear.

    METHODS validateplatenumber FOR VALIDATE ON SAVE
      IMPORTING keys FOR car~validateplatenumber.

ENDCLASS.

CLASS lhc_car IMPLEMENTATION.

  METHOD get_instance_features.



    result = VALUE #( FOR key IN keys
                      ( %tky                   = key-%tky

                        %field-img      = COND #( WHEN key-%is_draft  = if_abap_behv=>mk-on
                                                         THEN if_abap_behv=>fc-o-enabled
                                                         ELSE if_abap_behv=>fc-o-disabled )

                      ) ).

*    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
*    ENTITY car
*      FIELDS ( caruuid img )
*      WITH CORRESPONDING #( keys )
*    RESULT DATA(cars)
*    FAILED failed.
*
*    result = VALUE #( FOR car IN cars
*                      ( %tky                   = car-%tky
*
*                        %field-img      = COND #( WHEN car-%is_draft  = if_abap_behv=>mk-on
*                                                         THEN if_abap_behv=>fc-o-enabled
*                                                         ELSE if_abap_behv=>fc-o-disabled )
*
*                      ) ).
*    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
*     ENTITY car
*        UPDATE FIELDS ( img )
*        WITH result.


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

  METHOD resume.
  ENDMETHOD.

  METHOD updatemanstatus.
  ENDMETHOD.

  METHOD validatemanyear.
  ENDMETHOD.

  METHOD validateplatenumber.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY car
    FIELDS (  platnum )
    WITH CORRESPONDING #( keys )
  RESULT DATA(cars).

    LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>).
      IF strlen( <car>-platnum ) = 9.
        DATA(string) = match( val = <car>-platnum regex = platenumber_pattern occ = 1 ).
      ELSE.
      ENDIF.
      IF string NE <car>-platnum.
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
