100 REM Apple /// Fujinet ISS Tracker110 INVOKE "REQUEST.INV","BGRAF.INV"120 net$=".NETWORK"130 url$="N:HTTP://api.open-notify.org/iss-now.json"140 longitudequery$="/iss_position/longitude"150 latitudequery$="/iss_position/latitude"160 timestampquery$="/timestamp"180 REM two 8 bit rows per array entry190 DIM satellite%(4)200 satellite%(0)=TEN("2050")210 satellite%(1)=TEN("A458")220 satellite%(2)=TEN("1A05")230 satellite%(3)=TEN("0A04")240 ON KBD GOTO 860260 DIM back%(8,8)270 DIM month$(12)280 DATA  Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec290 FOR i%=0 TO 11:READ month$(i%):NEXT i%300 OPEN #2,".grafix"320 PERFORM initgrafix330 PERFORM grafixmode(%1,%1)340 PERFORM gload."a3map3"350 PERFORM grafixon400 GOSUB 1000:REM Get ISS Position405 GOSUB 2000:REM Get time410 PERFORM pencolor(%15)420 PERFORM fillcolor(%0)425 PERFORM xfroption(%0)430 PERFORM moveto(%0,%32)440 PRINT #2;" ** ISS Position ** "442 PERFORM moveto(%0,%24)445 PRINT #2;"Longitude Latitude  "450 PERFORM moveto(%0,%16)460 PRINT #2;longitude462 PERFORM moveto(%70,%16)464 PRINT #2;latitude490 PERFORM moveto(%0,%8)495 PRINT #2;" ";hour$;":";minutes$;"  ";day$;" ";month$(month%);" ";year$500 x%=(140/360)*(INT(longitude)+180)-4510 y%=(160/180)*(INT(latitude)+90)+32+4515 GOSUB 3200:REM restore background520 GOSUB 3000:REM save existing background for sat pos530 PERFORM pencolor(%15)535 PERFORM fillcolor(%0)536 PERFORM xfroption(%1)540 PERFORM moveto(%x%,%y%)550 PERFORM drawimage(@satellite%(0),%1,%0,%0,%8,%8)560 xold%=x%:yold%=y%600 FOR d=0 TO 5000:NEXT d:REM delay a bit 620 GOTO 400:REM go do it all again850 REM Exit if we get a keypress860 TEXT870 PERFORM release:PERFORM release:PERFORM release880 INVOKE:CLOSE890 END1000 REM open network dev and get iss position1010 OPEN #1,net$1020 cnum=ASC("O")1030 mode%=12:REM Read and Write1040 trans%=128:REM ??1050 ccmd$=CHR$(mode%)+CHR$(trans%)+url$+CHR$(0)+CHR$(LEN(url$))1060 clist$=CHR$(LEN(ccmd$)-1)+ccmd$1070 PERFORM CONTROL(%cnum,@clist$)net$1080 REM Set channel mode json1090 cnum=2521100 ccmd$=CHR$(1)1110 clist$=CHR$(1)+ccmd$1120 PERFORM CONTROL(%cnum,@clist$)net$1130 REM Parse the JSON1140 cnum=ASC("P"):REM Do the parse1150 clist$=CHR$(0)1160 PERFORM CONTROL(%cnum,@clist$)net$1180 REM Query for timestamp 1190 cnum=ASC("Q"):REM Query1200 ccmd$=timestampquery$+CHR$(LEN(timestampquery$))1210 clist$=CHR$(LEN(ccmd$)-1)+ccmd$1220 PERFORM CONTROL(%cnum,@clist$)net$1230 INPUT #1;result$1240 time=VAL(result$)1250 REM Query for Longitude 1260 cnum=ASC("Q"):REM Query1270 ccmd$=longitudequery$+CHR$(LEN(longitudequery$))1280 clist$=CHR$(LEN(ccmd$)-1)+ccmd$1290 PERFORM CONTROL(%cnum,@clist$)net$1300 INPUT #1;result$1310 longitude=VAL(result$)1320 REM Query for Latitude 1330 cnum=ASC("Q"):REM Query1340 ccmd$=latitudequery$+CHR$(LEN(latitudequery$))1350 clist$=CHR$(LEN(ccmd$)-1)+ccmd$1360 PERFORM CONTROL(%cnum,@clist$)net$1370 INPUT #1;result$1380 latitude=VAL(result$)1390 CLOSE #11400 RETURN2000 REM get time/date from the basic variables2010 REM lazy option so we don't have to convert the unix timestamp2050 year$="20"+LEFT$(DATE$,2)2060 month%=VAL(MID$(DATE$,4,2))2070 day$=RIGHT$(DATE$,2)2080 hour$=LEFT$(TIME$,2)2090 minutes$=MID$(TIME$,4,2)2100 RETURN3000 REM save background3010 FOR y1%=0 TO 73020   FOR x1%=0 TO 73025     PERFORM moveto(%(x%+x1%),%(y%+y1%-7))3030     back%(x1%,y1%)=EXFN%.XYCOLOR3040     NEXT x1%3050   NEXT y1%3060 RETURN3200 REM redraw background3210 FOR y1%=0 TO 73220   FOR x1%=0 TO 73230     PERFORM xfroption(%0)3240     PERFORM pencolor(%back%(x1%,y1%))3250     PERFORM dotat(%(xold%+x1%),%(yold%+y1%-7))3260     NEXT x1%3270   NEXT y1%3280 RETURN