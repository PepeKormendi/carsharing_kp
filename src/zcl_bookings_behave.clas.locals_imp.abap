CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateBookPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateBookPrice.

    METHODS setBookingNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingNumber.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCustomer.
    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateDates.
    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingDate.
    METHODS DefaultValuesFunction FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~DefaultValuesFunction.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculateBookPrice.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
  ENTITY Booking BY \_Car
    FIELDS ( Dailyprice )
    WITH CORRESPONDING #( keys )
  RESULT DATA(cars).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Booking
      FIELDS (  BookedFrom BookedTo BookPrice )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      IF <booking>-BookedFrom IS NOT INITIAL
      AND <booking>-Bookedto IS NOT INITIAL
      AND <booking>-Bookedto GE <booking>-BookedFrom.
        DATA(lv_days) = <booking>-Bookedto - <booking>-BookedFrom + 1.
        LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>) .
          <booking>-BookPrice = <car>-Dailyprice * lv_days.
          MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
             ENTITY Booking
               UPDATE  FIELDS ( BookPrice )
               WITH CORRESPONDING #( bookings ).
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD setBookingNumber.
    DATA max_bookingid TYPE /dmo/booking_id.
    DATA bookings_update TYPE TABLE FOR UPDATE zkp_i_cars\\Booking.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Booking BY \_Car
      FIELDS ( CarUUID )
      WITH CORRESPONDING #( keys )
    RESULT DATA(cars).

    LOOP AT cars INTO DATA(car).
      READ ENTITIES OF zkp_i_cars IN LOCAL MODE
        ENTITY Car BY \_Booking
          FIELDS ( BookingID )
          WITH VALUE #( ( %tky = car-%tky ) )
        RESULT DATA(bookings).

      max_bookingid = '0000'.
      LOOP AT bookings INTO DATA(booking).
        IF booking-BookingID > max_bookingid.
          max_bookingid = booking-BookingID.
        ENDIF.
      ENDLOOP.


      LOOP AT bookings INTO booking WHERE BookingID IS INITIAL.
        max_bookingid += 1.
        APPEND VALUE #( %tky      = booking-%tky
                        BookingID = max_bookingid
                      ) TO bookings_update.

      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY booking
        UPDATE FIELDS ( BookingID )
        WITH bookings_update.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY Booking
      FIELDS (  CustomerID )
      WITH CORRESPONDING #( keys )
     RESULT DATA(bookings).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
     ENTITY Booking BY \_Car
      FROM CORRESPONDING #( bookings )
     LINK DATA(car_booking_links).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    customers = CORRESPONDING #( bookings DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).

    IF  customers IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM /dmo/customer FIELDS customer_id
                                FOR ALL ENTRIES IN @customers
                                WHERE customer_id = @customers-customer_id
      INTO TABLE @DATA(valid_customers).
    ENDIF.

    LOOP AT bookings INTO DATA(booking).
      APPEND VALUE #(  %tky               = booking-%tky
                       %state_area        = 'VALIDATE_CUSTOMER' ) TO reported-booking.

      IF booking-CustomerID IS  INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                         %msg                = NEW /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>enter_customer_id
                                                                severity = if_abap_behv_message=>severity-error )
                        %path               = VALUE #( car-%tky = car_booking_links[ KEY id  source-%tky = booking-%tky ]-target-%tky )
                        %element-CustomerID = if_abap_behv=>mk-on
                       ) TO reported-booking.

      ELSEIF booking-CustomerID IS NOT INITIAL AND NOT line_exists( valid_customers[ customer_id = booking-CustomerID ] ).
        APPEND VALUE #(  %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                         %msg                = NEW /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>customer_unkown
                                                                customer_id = booking-customerId
                                                                severity = if_abap_behv_message=>severity-error )
                        %path               = VALUE #( car-%tky = car_booking_links[ KEY id  source-%tky = booking-%tky ]-target-%tky )
                        %element-CustomerID = if_abap_behv=>mk-on
                       ) TO reported-booking.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Booking
      FIELDS (  BookedFrom BookedTo CarUUID )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).
    IF bookings IS NOT INITIAL.

    ENDIF.
    LOOP AT bookings INTO DATA(booking).

      APPEND VALUE #(  %tky               = booking-%tky
                       %state_area        = 'VALIDATE_DATES' ) TO reported-booking.

      IF booking-BookedFrom IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_begin_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-BookedFrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-BookedTo IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg                = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_end_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-BookedTo   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-BookedTo < booking-BookedFrom AND booking-BookedFrom IS NOT INITIAL
                                           AND booking-BookedTo IS NOT INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW /dmo/cm_flight_messages(
                                                                textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                                begin_date = booking-BookedFrom
                                                                end_date   = booking-BookedTo
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BookedFrom = if_abap_behv=>mk-on
                        %element-BookedTo   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      IF booking-BookedFrom < cl_abap_context_info=>get_system_date( ) AND booking-BookedFrom IS NOT INITIAL.
        APPEND VALUE #( %tky               = booking-%tky ) TO failed-booking.

        APPEND VALUE #( %tky               = booking-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                begin_date = booking-BookedFrom
                                                                textid     = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BookedFrom = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setBookingDate.
*    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
*    ENTITY Booking
*      FIELDS ( BookingDate )
*      WITH CORRESPONDING #( keys )
*    RESULT DATA(bookings).
*
*    DELETE bookings WHERE BookingDate IS NOT INITIAL.
*    CHECK bookings IS NOT INITIAL.
*
*    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
*      <booking>-BookingDate = cl_abap_context_info=>get_system_date( ).
*    ENDLOOP.
*
*    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
*      ENTITY Booking
*        UPDATE  FIELDS ( BookingDate )
*        WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

  METHOD DefaultValuesFunction.
    DATA bookings_update TYPE TABLE FOR UPDATE zkp_i_cars\\Booking.

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Booking BY \_Car
      FIELDS ( CurrencyCode )
      WITH CORRESPONDING #( keys )
    RESULT DATA(cars).

    READ ENTITIES OF zkp_i_cars IN LOCAL MODE
    ENTITY Booking
      FIELDS (  CurrencyCode BookingDate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-BookingDate = cl_abap_context_info=>get_system_date( ).
      LOOP AT cars ASSIGNING FIELD-SYMBOL(<car>).
        <booking>-CurrencyCode = <car>-CurrencyCode.
      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zkp_i_cars IN LOCAL MODE
      ENTITY Booking
        UPDATE  FIELDS ( CurrencyCode BookingDate )
        WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
