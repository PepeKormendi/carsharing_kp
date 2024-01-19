CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculatebookprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatebookprice.

    METHODS setbookingnumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingnumber.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecustomer.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatedates.
    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingdate.
    METHODS defaultvaluesfunction FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~defaultvaluesfunction.
    METHODS setcustomerlink FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~setcustomerlink.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR booking RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR booking RESULT result.
    METHODS validatedatesbook FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatedatesbook.
    METHODS convertbookprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~convertbookprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculatebookprice.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
  ENTITY booking BY \_car
    FIELDS ( dailyprice )
    WITH CORRESPONDING #( keys )
  RESULT DATA(cars).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS (  bookedfrom bookedto bookprice )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      IF <booking>-bookedfrom IS NOT INITIAL
      AND <booking>-bookedto IS NOT INITIAL
      AND <booking>-bookedto GE <booking>-bookedfrom.
        DATA(lv_days) = <booking>-bookedto - <booking>-bookedfrom + 1.
        LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>) .
          <booking>-bookprice = <car>-dailyprice * lv_days.
          MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
             ENTITY booking
               UPDATE FIELDS ( bookprice )
               WITH CORRESPONDING #( bookings ).
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD setbookingnumber.
    DATA max_bookingid TYPE /dmo/booking_id.
    DATA bookings_update TYPE TABLE FOR UPDATE zkp_i_cars\\booking.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking BY \_car
      FIELDS ( caruuid )
      WITH CORRESPONDING #( keys )
    RESULT DATA(cars).

    LOOP AT cars INTO DATA(car).
      READ ENTITIES OF zkp_i_cars IN LOCAL MODE
        ENTITY car BY \_booking
          FIELDS ( bookingid )
          WITH VALUE #( ( %tky = car-%tky ) )
        RESULT DATA(bookings).

      max_bookingid = '0000'.
      LOOP AT bookings INTO DATA(booking).
        IF booking-bookingid > max_bookingid.
          max_bookingid = booking-bookingid.
        ENDIF.
      ENDLOOP.


      LOOP AT bookings INTO booking WHERE bookingid IS INITIAL.
        max_bookingid += 1.
        APPEND VALUE #( %tky      = booking-%tky
                        bookingid = max_bookingid
                      ) TO bookings_update.

      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY booking
        UPDATE FIELDS ( bookingid )
        WITH bookings_update.

  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY booking
      FIELDS (  customeruuid )
      WITH CORRESPONDING #( keys )
     RESULT DATA(bookings).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY booking BY \_car
      FROM CORRESPONDING #( bookings )
     LINK DATA(car_booking_links).

    DATA customers TYPE SORTED TABLE OF zszakd_customer WITH UNIQUE KEY customer_uuid.

    customers = CORRESPONDING #( bookings DISCARDING DUPLICATES MAPPING customer_uuid = customeruuid EXCEPT * ).

    IF  customers IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM zszakd_customer FIELDS customer_uuid
                                FOR ALL ENTRIES IN @customers
                                WHERE customer_uuid = @customers-customer_uuid
      INTO TABLE @DATA(valid_customers).
    ENDIF.

    LOOP AT bookings INTO DATA(booking).
      APPEND VALUE #(  %tky               = booking-%tky
                       %state_area        = 'VALIDATE_CUSTOMER' ) TO reported-booking.

      IF booking-customeruuid IS  INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Unvalid Customer' )
*                        %path               = VALUE #( car-%tky = car_booking_links[ KEY id  source-%tky = booking-%tky ]-target-%tky )
                        %element-customeruuid = if_abap_behv=>mk-on
                       ) TO reported-booking.

      ELSEIF booking-customeruuid IS NOT INITIAL AND NOT line_exists( valid_customers[ customer_uuid = booking-customeruuid ] ).
        APPEND VALUE #(  %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Customer unknown' )
*                        %path               = VALUE #( car-%tky = car_booking_links[ KEY id  source-%tky = booking-%tky ]-target-%tky )
                        %element-customeruuid = if_abap_behv=>mk-on
                       ) TO reported-booking.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validatedates.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS (  bookedfrom bookedto caruuid )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).
    IF bookings IS NOT INITIAL.

    ENDIF.
    LOOP AT bookings INTO DATA(booking).

*      APPEND VALUE #(  %tky               = booking-%tky
*                       %state_area        = 'VALIDATE_DATES' ) TO reported-booking.

      IF booking-bookedfrom IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Enter begin date' )
                        %element-bookedfrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedto IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Enter end date' )
                        %element-bookedto   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedto < booking-bookedfrom AND booking-bookedfrom IS NOT INITIAL
                                           AND booking-bookedto IS NOT INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Begin date must be earlier or on the same day as End date' )
                        %element-bookedfrom = if_abap_behv=>mk-on
                        %element-bookedto   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedfrom < cl_abap_context_info=>get_system_date( ) AND booking-bookedfrom IS NOT INITIAL.
        APPEND VALUE #( %tky               = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Begin date must be later then the present day' )
                        %element-bookedfrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setbookingdate.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS ( bookingdate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DELETE bookings WHERE bookingdate IS NOT INITIAL.
    CHECK bookings IS NOT INITIAL.

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-bookingdate = cl_abap_context_info=>get_system_date( ).
    ENDLOOP.

    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
      ENTITY booking
        UPDATE  FIELDS ( bookingdate )
        WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

  METHOD defaultvaluesfunction.
    DATA bookings_update TYPE TABLE FOR UPDATE zkp_i_cars\\booking.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking BY \_car
      FIELDS ( currencycode )
      WITH CORRESPONDING #( keys )
    RESULT DATA(cars).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS (  currencycode bookingdate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-bookingdate = cl_abap_context_info=>get_system_date( ).
      LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>).
        <booking>-currencycode = <car>-currencycode.
      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
      ENTITY booking
        UPDATE  FIELDS ( currencycode bookingdate )
        WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

  METHOD setcustomerlink.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS (  customeruuid custname customername )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).
    IF bookings IS NOT INITIAL.
      SELECT customeruuid, lastname FROM zszakd_i_customer
      FOR ALL ENTRIES IN @bookings WHERE customeruuid = @bookings-customeruuid
      INTO TABLE @DATA(customers).
    ENDIF.

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-custname = <booking>-customeruuid.
      <booking>-customername = VALUE #( customers[ customeruuid = <booking>-customeruuid ]-lastname OPTIONAL ).
    ENDLOOP.

    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
      ENTITY booking
        UPDATE  FIELDS ( custname )
        WITH CORRESPONDING #( bookings ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validatedatesbook.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
      ENTITY booking
        FIELDS (  bookedfrom bookedto caruuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).
    IF bookings IS NOT INITIAL.

    ENDIF.
    LOOP AT bookings INTO DATA(booking).

*      APPEND VALUE #(  %tky               = booking-%tky
*                       %state_area        = 'VALIDATE_DATES' ) TO reported-booking.

      IF booking-bookedfrom IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Enter begin date' )
                        %element-bookedfrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedto IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Enter end date' )
                        %element-bookedto   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedto < booking-bookedfrom AND booking-bookedfrom IS NOT INITIAL
                                           AND booking-bookedto IS NOT INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Begin date must be earlier or on the same day as End date' )
                        %element-bookedfrom = if_abap_behv=>mk-on
                        %element-bookedto   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedfrom < cl_abap_context_info=>get_system_date( ) AND booking-bookedfrom IS NOT INITIAL.
        APPEND VALUE #( %tky               = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
*                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Begin date must be later then the present day' )
                        %element-bookedfrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-bookedfrom >= cl_abap_context_info=>get_system_date( ) AND  booking-bookedfrom <= booking-bookedto.
        SELECT * FROM zkp_car_bookings INTO TABLE @DATA(lt_bookings) WHERE parent_uuid  =  @booking-caruuid
                                                                       AND booking_uuid NE @booking-bookinguuid.






        LOOP AT  lt_bookings ASSIGNING FIELD-SYMBOL(<ls_booking>) WHERE booked_from GE booking-bookedfrom
                                                                    AND booked_from LE booking-bookedto.
          DATA(overlap) = abap_true.

        ENDLOOP.

        LOOP AT  lt_bookings ASSIGNING <ls_booking> WHERE booked_to LE booking-bookedfrom
                                                      AND booked_to GE booking-bookedto.
          overlap = abap_true.

        ENDLOOP.

        reported-booking = SWITCH #( overlap
                             WHEN abap_true THEN
                             VALUE #( BASE reported-booking ( %tky = booking-%tky
                                                            %msg = new_message_with_text(
                                                              severity = if_abap_behv_message=>severity-error
                                                              text     = 'There is another booking for this car in the given period' )
                                                              %element-bookedfrom = if_abap_behv=>mk-on  ) )
                              ELSE reported-booking ).

        failed-booking = SWITCH #(  overlap WHEN abap_true THEN VALUE #( BASE failed-booking ( %tky = booking-%tky ) )
                                            ELSE failed-booking ).

      ENDIF.


    ENDLOOP.
  ENDMETHOD.

  METHOD convertbookprice.
*    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
*    ENTITY booking BY \_car
*      FIELDS ( dailyprice )
*      WITH CORRESPONDING #( keys )
*    RESULT DATA(cars).
    DATA: lt_cur_range TYPE RANGE OF currency_code.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY booking
      FIELDS (  curcodedummy currencycode bookprice priceinhuf )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      IF <booking>-curcodedummy IS NOT INITIAL
      AND <booking>-bookprice IS NOT INITIAL
      AND <booking>-currencycode IS NOT INITIAL.
        lt_cur_range = VALUE #( sign = 'I' option = 'EQ'
        ( low = <booking>-curcodedummy )
        ( low = <booking>-currencycode ) ).
        SELECT * FROM zszakd_curren_ex INTO TABLE @DATA(lt_currency)
        WHERE currency_code IN @lt_cur_range.
        DATA(lv_from) = VALUE #(  lt_currency[ currency_code = <booking>-currencycode ]-exchange_rate DEFAULT 0 ).
        DATA(lv_to) = VALUE #(  lt_currency[ currency_code = <booking>-curcodedummy ]-exchange_rate DEFAULT 0 ).

        <booking>-priceinhuf = COND #( WHEN lv_from NE 0 THEN lv_to / lv_from * <booking>-bookprice ).
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
       ENTITY booking
         UPDATE FIELDS ( priceinhuf )
         WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
