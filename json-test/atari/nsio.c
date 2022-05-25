/*
  This module provides "nXXXX()" functions for
  talking to the #FujiNet N: device via direct SIO Calls.

  From "Network Testing tools"
  by Thomas Cherryhomes <thom.cherryhomes@gmail.com>
  (Released under GPL 3.0)

  Last modified: 2022-05-25
*/

#include <atari.h>
#include <string.h>
#include <stdlib.h>
#include <peekpoke.h>
#include "sio.h"
#include "nsio.h"

#define FUJINET_SIO_DEVICEID 0x71
#define TIMEOUT 0x1f

unsigned char nopen(unsigned char unit, char* buf, unsigned char aux1)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'O';
  OS.dcb.dstats = 0x80;
  OS.dcb.dbuf = buf;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = 256;
  OS.dcb.daux1 = aux1;
  OS.dcb.daux2 = 0; // NO TRANSLATION!
  return siov();
}

unsigned char nclose(unsigned char unit)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'C';
  OS.dcb.dstats = 0x00;
  OS.dcb.dbuf = NULL;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = 0;
  OS.dcb.daux1 = 0;
  OS.dcb.daux2 = 0;
  return siov();
}

unsigned char nread(unsigned char unit, char* buf, unsigned short len)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'R';
  OS.dcb.dstats = 0x40;
  OS.dcb.dbuf = buf;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = len;
  OS.dcb.daux = len;
  return siov();
}

unsigned char nwrite(unsigned char unit, char* buf, unsigned short len)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'W';
  OS.dcb.dstats = 0x80;
  OS.dcb.dbuf = buf;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = len;
  OS.dcb.daux = len;
  return siov();
}

unsigned char nstatus(unsigned char unit)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'S';
  OS.dcb.dstats = 0x40;
  OS.dcb.dbuf = OS.dvstat;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = sizeof(OS.dvstat);
  OS.dcb.daux1 = 0;
  OS.dcb.daux2 = 0;
  return siov();
}

unsigned char nchanmode(unsigned char unit, unsigned char mode)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 0xFC;
  OS.dcb.dstats = 0x80;
  OS.dcb.dbuf = NULL;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = 0;
  OS.dcb.daux1 = 0;
  OS.dcb.daux2 = mode;
  return siov();
}

unsigned char njsonparse(unsigned char unit)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'P';
  OS.dcb.dstats = 0x80;
  OS.dcb.dbuf = NULL;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = 256;
  OS.dcb.daux1 = 0;
  OS.dcb.daux2 = 1; // ???
  return siov();
}

unsigned char njsonQuery(unsigned char unit, char *buf)
{
  OS.dcb.ddevic = FUJINET_SIO_DEVICEID;
  OS.dcb.dunit = unit;
  OS.dcb.dcomnd = 'Q';
  OS.dcb.dstats = 0x80;
  OS.dcb.dbuf = buf;
  OS.dcb.dtimlo = TIMEOUT;
  OS.dcb.dbyt = 256;
  OS.dcb.daux1 = 0;
  OS.dcb.daux2 = 0; // ???
  return siov();
}
