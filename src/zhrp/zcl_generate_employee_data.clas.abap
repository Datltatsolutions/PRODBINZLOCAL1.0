CLASS zcl_generate_employee_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_EMPLOYEE_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztemployee.

*   fill internal table (itab)
    itab = VALUE #(
       ( empid = 'E1' empfirstname = 'Van A' emplastname = 'Nguyen' emppersid = '205267812'
       empssn = '436786521' empgender = 'M' emptitle = 'Mr.' empmarital = 'S' empcountry = 'VN'
       emphomestreet = '12 Ton Duc Thang' emphomecity = 'Ho Chi Minh' emphomestate = 'OH'
       empprivatephone = '+8411111111' empjobtitle = 'CFO' emporgunit = 'F & A' emphiredate = '20150101'
       empagreement = 'Permanent' emphours = '40' empofficeaddr = '5 Nguyen Thi Thap' empofficecity = 'One IBC'
       empcommphone = '+8411111111' empmobilephone = '+8422222222' empemail = 'vannguyen@one.com')

       ( empid = 'E2' empfirstname = 'Thi B' emplastname = 'Nguyen' emppersid = '208293098'
       empssn = '453899001' empgender = 'F' emptitle = 'Ms.' empmarital = 'S' empcountry = 'VN'
       emphomestreet = '255 Nguyen Huu Tho' emphomecity = 'Da Nang' emphomestate = 'VT'
       empprivatephone = '+8411111111' empjobtitle = 'Director of HR' emporgunit = 'HR & IT' emphiredate = '20150102'
       empagreement = 'Permanent' emphours = '40' empofficeaddr = '5 Nguyen Thi Thap' empofficecity = 'One IBC'
       empcommphone = '+8411111111' empmobilephone = '+8422222222' empemail = 'bnguyen@one.com')

       ( empid = 'E3' empfirstname = 'Mai' emplastname = 'Duong' emppersid = '222222222'
       empssn = '389728430' empgender = 'F' emptitle = 'Mrs.' empmarital = 'M' empcountry = 'VN'
       emphomestreet = '90 Nguyen Phuc Tan' emphomecity = 'Hanoi' emphomestate = 'OH'
       empprivatephone = '+8411111111' empjobtitle = 'CTO (Manufacturing)' emporgunit = 'Mfg.' emphiredate = '20160103'
       empagreement = 'Temporary' emphours = '40' empofficeaddr = '5 Nguyen Thi Thap' empofficecity = 'One IBC'
       empcommphone = '+8411111111' empmobilephone = '+8422222222' empemail = 'duongmai@one.com')

       ( empid = 'E4' empfirstname = 'Cong' emplastname = 'Tran' emppersid = '1002991000'
       empssn = '873432433' empgender = 'M' emptitle = 'Mr.' empmarital = 'S' empcountry = 'VN'
       emphomestreet = '85 Tran Hung Dao' emphomecity = 'Quy Nhon' emphomestate = 'OH'
       empprivatephone = '+8411111111' empjobtitle = 'VP of Sales' emporgunit = 'Sales' emphiredate = '20170104'
       empagreement = 'Permanent' emphours = '40' empofficeaddr = '5 Nguyen Thi Thap' empofficecity = 'One IBC'
       empcommphone = '+8411111111' empmobilephone = '+8422222222' empemail = 'congtran@one.com')

       ( empid = 'E5' empfirstname = 'Van Duc' emplastname = 'Nguyen' emppersid = '1000000000'
       empssn = '764332433' empgender = 'M' emptitle = 'Mr.' empmarital = 'D' empcountry = 'VN'
       emphomestreet = '1 Nguyen Hue' emphomecity = 'Da Lat' emphomestate = 'OH'
       empprivatephone = '+8411111111' empjobtitle = 'Procurement Director' emporgunit = 'Proc.' emphiredate = '20180105'
       empagreement = 'Permanent' emphours = '40' empofficeaddr = '5 Nguyen Thi Thap' empofficecity = 'One IBC'
       empcommphone = '+8411111111' empmobilephone = '+8422222222' empemail = 'ducnguyen@one.com')
    ).

*   delete existing entries in the database table
    DELETE FROM ztemployee.

*   insert the new table entries
    INSERT ztemployee FROM TABLE @itab.

*   output the result as a console message
    out->write( |{ sy-dbcnt } employee entries inserted successfully!| ).

  ENDMETHOD.
ENDCLASS.
