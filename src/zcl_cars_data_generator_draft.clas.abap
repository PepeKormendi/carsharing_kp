CLASS zcl_cars_data_generator_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_cars_data_generator_draft IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " Travels
    out->write( ' --> ZKP_CARS' ).

    DELETE FROM zkp_cars_d.                             "#EC CI_NOWHERE
    DELETE FROM zkp_cars.                               "#EC CI_NOWHERE

    " Add some comments here
    DELETE FROM zkp_cars_d.                             "#EC CI_NOWHERE
    DELETE FROM zkp_cars.                               "#EC CI_NOWHERE
    DELETE FROM zkp_car_booki_d.                        "#EC CI_NOWHERE
    DELETE FROM zkp_car_bookings.                       "#EC CI_NOWHERE

    DATA: lt_cars TYPE STANDARD TABLE OF zkp_cars.
    DATA: lt_bookings TYPE STANDARD TABLE OF zkp_car_bookings.

    lt_cars = VALUE #(
    ( car_uuid = '9BFE3AF01C5CD99E180040C2EA63A2F7' platenum = 'AB-AB-001' brand = 'BMW' model = '320d' enginetype = 'D' yearmanufact = '2022'
    dailyprice = 100 currency_code = 'EUR' status = 'J' numofseats = 5 )
    ( car_uuid = '9BFE3AF01C5CD99E180040C2EA63A2F9' platenum = 'DB-AB-321' brand = 'Skoda' model = 'Octavia' enginetype = 'B' yearmanufact = '2021'
    dailyprice = 85 currency_code = 'EUR' status = 'J' numofseats = 6 )
    ).

    lt_bookings = VALUE #(
    ( booking_uuid = '6FFE3AF01C5CD99E180040C2EA63A2F4' parent_uuid = '9BFE3AF01C5CD99E180040C2EA63A2F7' booking_date = '20230930'
    currency_code = 'EUR' book_price = 500 customer_id = '000594' booked_from = '20231001' booked_to = '20231006' booking_id = '00000001' )
        ( booking_uuid = '6FFE3AF01C5CD99E180040C2EA63A2F5' parent_uuid = '9BFE3AF01C5CD99E180040C2EA63A2F7' booking_date = '20231001'
    currency_code = 'EUR' book_price = 200 customer_id = '000594' booked_from = '20231010' booked_to = '20231011' booking_id = '00000002' )
     ).
    INSERT zkp_cars FROM TABLE @lt_cars.
    COMMIT WORK.
    INSERT zkp_car_bookings FROM TABLE @lt_bookings.
    COMMIT WORK.


    " bookings
    out->write( ' --> /DMO/A_BOOKING_D' ).





  ENDMETHOD.
ENDCLASS.
