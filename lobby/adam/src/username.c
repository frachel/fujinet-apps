/**
 * @brief FujiNet Lobby for Adam
 * @author Thomas Cherryhomes
 * @email thom dot cherryhomes at gmail dot com
 * @license gpl v. 3, see LICENSE for details.
 */

#include <stdlib.h>
#include <smartkeys.h>
#include <string.h>
#include "appkey.h"
#include "username.h"
#include "state.h"
#include "input.h"

extern unsigned char response[1024];
extern State state;
char _username[32];

void username_set(void)
{
  smartkeys_clear();
  smartkeys_display(NULL,NULL,NULL,NULL,NULL,NULL);
  smartkeys_status("\n  PLEASE ENTER A USER NAME.");
  input_line(0,19,0,username,128,NULL);

  if (appkey_write(0x0001,0x01,0x00,_username) != 0x80)
    {
      smartkeys_display(NULL,NULL,NULL,NULL,NULL,NULL);
      smartkeys_status("\n  COULD NOT WRITE APPKEY.");
      state=HALT;
    }
}

void username_get(void)
{
  strcpy(username,response);
  state=FETCH;
}

void username(void)
{
  memset(response,0,sizeof(response));
  appkey_read(0x0001,0x01,0x00,response);
  
  if (response[0]==0x00)
    username_set();
  else
    username_get();
}
