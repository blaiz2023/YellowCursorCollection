program yellowcursorcollection;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  main,
  gossgui,
  gossdat,
  gossimg,
  gossio,
  gossnet,
  gossroot,
  gosssnd,
  gosswin,
  gosszip,
  gossjpg,
  gossteps,
  gosstext,
  gossfast,
  gosswin2,
  gossgame,
  gamefiles;
  { you can add units after this }


//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R yellowcursorcollection-256.res}

//include version information
{$R ver.res}

begin
//(1)false=event driven disabled, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(true,false,not isconsole);
end.

