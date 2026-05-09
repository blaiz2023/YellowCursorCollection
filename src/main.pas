unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define jpeg} {$endif}
{$ifdef WIN64}{$define 64bit}{$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d`3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps{$ifdef gamecore}, gossgame ,gamefiles{$endif};
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 2.00.075 (for Archive Content)
//## Items.................... 3
//## Last Updated ............ 09may2026, 08may2026, 06may2026, 05may2026, 04may2026, 03may2026
//## Lines of Code............ 4,000+
//## Origin .................. Human generated and maintained
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | archive contents       | packed files      | 2.00.075  | 09may2026   | Contents of archive
//## | tapp                   | tbasicapp         | 1.00.022  | 09may2026   | App as host
//## | tarchive               | tbasicscroll      | 1.00.1373 | 09may2026   | Interactive archive - 06may2026, 05may2026, 04may2026, 03may2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy           :boolean=false;
   iapp                 :tobject=nil;

const

   //app specific images
   tepREADME20          =tepCustomBASE20 + 0;
   tepLicense20         =tepCustomBASE20 + 1;
   tepScrollDown20      =tepCustomBASE20 + 2;
   tepMask20            =tepCustomBASE20 + 3;

   //file types
   ft_binary            =0;
   ft_text              =1;
   ft_image             =2;
   ft_pic8              =3;
   ft_midi              =4;
   ft_music             =5;
   ft_max               =5;

   //mask modes
   mm_all               =0;
   mm_simple            =1;
   mm_custom            =2;
   mm_custom2           =3;
   mm_max               =3;

   //replace mode
   rm_cancel            =0;
   rm_skipall           =1;
   rm_replaceall        =2;
   rm_max               =2;

type

   tarchive=class(tbasicscroll)
   private

    istartfile               :string;
    ifirstfileload           :boolean;
    imaskCustom              :string;
    imaskCustom2             :string;
    imaskmode                :longint32;
    ilastmaskmode            :longint32;

    itimerfast               :longint64;
    itimer100                :longint64;
    itimer250                :longint64;
    itimer500                :longint64;
    imidiFastTimer           :longint64;

    isystem__about           :string;
    isystem__readme          :string;
    isystem__license         :string;
    isystem__aboutOK         :boolean;
    isystem__readmeOK        :boolean;
    isystem__licenseOK       :boolean;

    iscrolltime__image          :longint32;
    iscrolltime__imageAnimated  :longint32;
    iscrolltime__text           :longint32;
    iscrolltime__midi           :longint32;
    iscrolltime__midiPlaying    :longint32;
    iscrolltime__other          :longint32;

    iautoscroll              :boolean;
    iautoscrollCOUNT         :longint32;

    ilastsaveone_filename    :string;
    ilastsaveall_folder      :string;

    ileftbar                 :tbasictoolbar;
    irightbar                :tbasictoolbar;
    isep1,isep2              :longint32;
    ibotbar                  :tbasictoolbar;
    itext                    :tbasicbwp;
    iimage                   :tbasicimgview;

    iroller255               :longint;
    irollerUP                :boolean;

    ipic8                    :tpre8;
    ipiccore8                :tpiccore8;
    iflashref                :string;

    imidivol                 :tsimpleint;
    imididevice              :tbasicsel;
    imidiLastTimeRef         :longint64;
    ibeatval                 :double;
    ibeatvalBass             :double;
    ijumpbar                 :tbasictoolbar;
    ijump                    :tbasicjump;

    ilist                    :tbasicmenu;
    imidilist                :tbasicmenu;
    ilistTab                 :string;
    ilastflash               :boolean;

    isublist                 :tdynamicinteger;
    itotal_compressed_size   :longint64;
    itotal_uncompressed_size :longint64;

    iinfvars                 :tfastvars2;
    ilastfiletype            :longint32;
    ilastfilename            :string;
    ilastfileext             :string;
    ilastfiledata            :tstr8;
    ilastplayfile            :string;
    icursorpreviewREF        :string;
    imask                    :tbasicset;
    ilastmaskREF             :string;
    imaskbar                 :tbasictoolbar;

    istatusbar               :tbasicstatus;

    i_type                   :longint32;
    i_filesize               :longint32;
    i_colors                 :longint32;
    i_cells                  :longint32;
    i_dimensions             :longint32;
    i_bits                   :longint32;
    i_fps                    :longint32;
    i_misc                   :longint32;
    i_words                  :longint32;
    i_chars                  :longint32;
    i_tracks                 :longint32;
    i_archive                :longint32;
    i_cursorSize             :longint32;
    i_max                    :longint32;

    function list__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    function midilist__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure __onclick(sender:tobject);
    procedure list__onclick(sender:tobject);
    procedure list__ondbclick(sender:tobject);
    procedure xcmd(xcode2:string);
    procedure xupdatebuttons;
    function getsettings:string;
    procedure setsettings(x:string);

    procedure master__stopAll;

    procedure midi__beatFlash;

    function cursor__formatSupported(const x:string):boolean;
    procedure cursor__preview;

    procedure dialog__suppressAllFormatOptions(x:boolean);

    function auto__scrollCountTrigger:longint32;
    function auto__scrollMustNext:boolean;
    function auto__scroll:boolean;
    procedure auto__setscroll(const x:boolean);

    function must__mode:longint32;
    procedure must__setmode(const x:longint32;const xdisableScroll:boolean);

    function file__count:longint32;
    function file__info(const xindex:longint;var xtep,xdatalen,xorgSize:longint32;var xpathname:string):boolean;
    function file__info2(const xindex:longint;var xdata:pointer;var xtep,xdatalen,xorgSize:longint32;var xcompressed:boolean;var xpathname:string):boolean;
    function file__findByName(const n:string;var xindex:longint):boolean;
    function file__findByNameb(const n:string):longint32;
    function file__findSystemFileByName(const n:string;var xindex:longint):boolean;
    function file__findSystemFileByNameb(const n:string):longint;
    procedure file__view(const n:string);
    procedure file__view2(const n:string;const xshowError:boolean);
    function file__foundByName(const n:string):boolean;
    procedure file__viewDefault;
    procedure file__setmask(const xmask:string;const xmaskmode:longint32);
    function file__subTOfullindex(const sindex:longint):longint;
    function file__type(const xfilename:string):longint;
    function file__excludeFilter:string;
    procedure file__loadfile;
    procedure file__prevfile;
    procedure file__nextfile;

    //media playback controls
    procedure file__playSync;
    function file__playInfoInSync:boolean;
    procedure file__playToggle;
    function file__playing:boolean;
    procedure file__play;
    function file__playlen:longint32;
    function file__playpos:longint32;
    procedure file__setplaypos(const xnewpos:longint);
    function file__canstop:boolean;
    procedure file__stop;
    function file__tracks:longint32;
    function file__speed:longint32;
    procedure file__setspeed(const x:longint32);
    function file__vol:longint32;
    procedure file__setvol(const x:longint32);

    //.temporary variable storage
    function sfound(const n:string):boolean;
    function sval(const n:string):string;
    procedure ssetval(const n,v:string);
    function ival(const n:string):longint32;
    procedure isetval(const n:string;const v:longint32);
    procedure setcelltext(xindex:longint;xtext:string);
    function xtempfolder(const xautocreate:boolean):string;
    procedure xcleantempfolder;

    function haveListIndex(const xmaskMode:longint32):boolean;
    function listIndex(const xmaskMode:longint32):longint32;
    function listPos(const xmaskMode:longint32):longint32;
    procedure setlistIndex(const xmaskMode,xval:longint32);
    procedure setlistPos(const xmaskMode,xval:longint32);
    function xpromptReplaceAll(const xmsg:string):longint;
    function xhelpval(const x:string):string;
    function xhelpval2(const x:string;const xfull:boolean):string;

   public

    //create
    constructor create(xparent:tobject;const xstartfile:string); virtual;
    constructor create2(xparent:tobject;xstartfile:string;xscroll,xstart:boolean); virtual;
    destructor destroy; override;
    procedure _ontimer(sender:tobject); override;

    //settings
    function settingsREF(const xfull:boolean):string;
    property settings                     :string        read getsettings         write setsettings;
    property celltext[xindex:longint]     :string                                 write setcelltext;

    //io
    function cansaveone:boolean;
    procedure saveone__tofile;

    function cansaveall:boolean;
    procedure saveall__tofolder(const xuseTempFolder:boolean);

   end;


{tapp}
   tapp=class(tbasicapp)
   private

    //core
    iloaded,ibuildingcontrol:boolean;
    isettingsref:string;

    itimer500         :longint64;
    iboxed            :tarchive;

    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

   end;


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function app__syncandsavesettings:boolean;


//support procs ----------------------------------------------------------------
function fastvars2__new:tfastvars2;


implementation

{$ifdef gui}
uses
    gossdat, archiveFiles;
{$endif}


const

mtep_README20
:array[0..382] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,1,70,73,68,65,84,120,1,220,83,49,138,132,64,16,108,143,3,17,12,140,54,51,48,18,5,127,32,251,0,19,13,140,125,134,96,160,153,176,207,240,1,6,70,126,192,196,124,65,49,48,89,196,23,8,154,205,217,115,204,158,238,112,235,93,178,193,54,56,211,109,85,151,61,99,55,192,219,154,128,39,187,92,46,68,85,85,238,144,85,85,65,150,101,160,40,10,184,174,11,231,243,153,227,220,110,55,136,162,72,248,68,4,69,218,182,165,15,99,158,78,39,176,109,27,12,195,0,81,20,65,150,101,168,235,26,198,113,100,20,138,33,142,70,133,208,65,161,60,207,105,133,24,163,233,186,78,226,56,6,66,8,36,73,2,125,223,239,112,223,247,9,39,244,157,186,95,187,174,19,210,52,37,248,246,81,100,207,220,84,244,8,176,120,89,22,230,62,221,63,158,162,255,0,95,43,132,151,125,100,135,21,9,194,238,71,253,170,119,40,132,153,127,169,232,222,71,216,15,216,23,236,147,243,60,67,211,52,16,4,1,96,85,154,166,17,211,52,65,146,36,70,161,13,201,2,42,52,12,195,
174,75,25,184,221,215,126,218,134,119,31,71,4,141,10,133,97,200,93,196,58,18,196,113,28,240,60,143,18,139,162,128,178,44,97,154,38,142,187,206,218,207,136,80,246,102,97,9,150,101,209,227,94,175,87,78,96,67,127,103,247,11,0,0,255,255,3,0,68,101,98,186,121,229,85,143,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_License20
:array[0..504] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,1,192,73,68,65,84,120,1,228,147,191,106,2,65,16,198,191,205,197,39,8,137,69,52,150,150,22,118,10,130,130,24,141,249,211,37,145,24,108,20,108,45,21,43,11,95,192,86,68,68,136,96,163,93,82,170,248,2,90,217,168,8,137,38,166,84,176,144,205,237,64,150,187,243,12,41,3,217,226,152,157,253,205,119,223,206,205,1,127,109,49,97,136,115,190,215,87,34,145,80,143,57,170,213,42,177,102,32,99,12,135,102,7,218,156,221,110,215,110,247,198,166,142,156,78,39,87,157,192,225,112,232,10,167,211,41,42,149,10,70,163,145,206,157,112,36,133,138,197,34,215,22,206,231,115,244,251,125,248,124,62,18,235,116,58,240,122,189,176,90,173,82,124,60,30,35,151,203,169,58,154,171,181,90,45,164,211,105,130,106,181,26,158,159,95,88,38,147,65,62,159,167,6,54,155,77,182,221,110,17,10,133,120,60,30,39,174,221,110,11,33,138,101,143,86,171,21,44,22,11,37,133,27,69,57,160,88,251,80,20,5,139,197,66,114,235,245,90,30,75,161,72,36,130,
229,114,73,7,225,112,88,2,198,96,31,71,66,175,243,119,184,92,46,212,235,117,136,251,198,98,49,188,127,124,226,228,248,72,167,99,198,189,190,45,136,161,102,39,147,73,238,241,120,112,123,119,207,212,161,66,163,241,196,187,221,46,202,229,50,251,238,81,161,80,96,169,84,106,135,235,245,122,196,145,35,183,219,141,205,102,131,199,248,3,53,54,24,12,66,228,140,107,31,167,190,16,212,209,243,112,148,13,6,3,4,2,1,248,253,126,12,135,67,68,175,110,116,179,34,68,205,184,139,203,107,226,200,145,227,236,20,165,82,105,167,208,232,232,39,110,247,27,27,171,127,185,39,23,198,159,214,56,229,90,173,201,100,130,108,54,171,115,175,155,108,45,44,166,220,102,179,105,83,50,158,205,102,66,72,238,255,65,240,5,0,0,255,255,3,0,157,74,186,202,254,87,55,190,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_scrollDown20
:array[0..204] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,0,148,73,68,65,84,120,1,236,146,93,14,0,17,12,132,75,246,46,226,254,135,17,151,177,107,68,69,106,253,189,120,34,17,73,107,190,214,20,209,93,219,14,24,99,222,109,81,20,60,82,228,156,35,173,181,12,83,8,161,91,32,222,87,13,168,33,228,128,181,182,151,74,241,101,144,247,94,141,72,237,27,70,183,7,185,229,142,206,122,132,106,48,179,246,1,223,32,79,48,121,83,231,254,94,152,60,2,4,34,254,67,12,153,77,170,6,150,73,176,152,147,178,195,153,71,101,106,104,157,59,144,16,192,17,235,109,46,126,207,67,14,124,0,0,0,255,255,3,0,42,157,58,128,142,210,101,159,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_mask20
:array[0..143] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,0,87,73,68,65,84,120,1,98,96,24,5,116,11,1,70,144,77,9,9,9,255,103,206,156,73,150,165,28,28,28,12,255,255,255,103,4,27,244,249,243,103,178,12,129,105,226,229,229,101,96,130,113,40,165,89,64,6,228,230,230,82,228,53,160,17,163,94,35,16,19,131,51,214,8,56,122,84,154,154,33,0,0,0,0,255,255,3,0,192,46,28,149,118,187,118,150,0,0,0,0,73,69,78,68,174,66,96,130);


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1200'
else if (xname='height')              then result:='900'

else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde - 31jan2026
else if (xname='msstore.name')        then result:='BlaizYellowCursorCollection'//optional - overrides default name for Clyde - 15apr2026

else if (xname='ver')                 then result:='2.00.075'
else if (xname='date')                then result:='09may2026'
else if (xname='name')                then result:='YellowCursorCollection'
else if (xname='web.name')            then result:='yellowcursorcollection'//used for website name
else if (xname='des')                 then result:='780 standard arrow pointers in various color and animation variants'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')


//------------------------------------------------------------------------------
//.special options - 04may2026 -------------------------------------------------

else if (xname='back.name')           then result:='Gradient Blue (Scrolling)'//default background name
else if (xname='splash.show')         then result:='0'//hide the splash screen

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
try

except;end;
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure m32(const sm:array of byte);//mono only
   begin

   tep__32( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure c(const sc:array of byte);//color only
   begin

   tep__20( xindex ,[0] ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m6(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle6 ,it_img32 );

   end;

begin

case xindex of

tepREADME20           :m( mtep_README20     );
tepLicense20          :m( mtep_License20    );
tepScrollDown20       :m( mtep_ScrollDown20 );
tepMask20             :m( mtep_Mask20       );

end;//case

end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


//support procs ----------------------------------------------------------------
function fastvars2__new:tfastvars2;
begin

result:=tfastvars2.create2( 60000 );//60K items

end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//111111111111111111111111111111
//## tboxed ####################################################################
constructor tarchive.create(xparent:tobject;const xstartfile:string);
begin

create2(xparent,xstartfile,false,true);

end;

constructor tarchive.create2(xparent:tobject;xstartfile:string;xscroll,xstart:boolean);
const
   vLeftWidth         =32;
   vRightWidth        =100-vLeftWidth;
   vTopHeight         =50;
   vBotHeight         =100-vTopHeight;

var
   p:longint;

   procedure fadd(xtep:longint32;const xlabel,xfilename,xhelp:string);
   begin

   if (xlabel<>'') then
      begin

      if (xtep=tepNone) then xtep:=tep__filetype202(xfilename,tepEdit20);

      ileftbar.add( xlabel ,xtep ,0 ,'view.'+xfilename ,strdefb( xhelp ,'Preview File|' + xfilename ) );

      end;

   end;

begin

//self
if classnameis('tboxed') then track__inc(satOther,1);
inherited create2(xparent,false,false);

//require gamecore support
need_gamecore;

//vars
oautoheight                  :=true;
ominheight                   :=1;
itimerfast                   :=slowms64;
itimer100                    :=slowms64;
itimer250                    :=slowms64;
itimer500                    :=slowms64;
imidiFastTimer               :=slowms64;
ilastflash                   :=false;
isublist                     :=tdynamicinteger.create;
itotal_compressed_size       :=0;
itotal_uncompressed_size     :=0;
iinfvars                     :=tfastvars2.create2(50000);
istartfile                   :=xstartfile;
ifirstfileload               :=true;

imaskMode                    :=mm_all;
ilastmaskmode                :=-1;
imaskCustom                  :='';
imaskCustom2                 :='';

ilastfiletype                :=ft_binary;
ilastfilename                :='?';//force system to update at least once
ilastfileext                 :='';
ilastfiledata                :=str__new8;
ilastplayfile                :='';
icursorpreviewREF            :='';
ilastmaskREF                 :='';
iroller255                   :=255;
irollerUP                    :=false;

isystem__about               :='';
isystem__readme              :='';
isystem__license             :='';

isystem__aboutOK             :=false;
isystem__readmeOK            :=false;
isystem__licenseOK           :=false;

ilastsaveone_filename        :='';
ilastsaveall_folder          :='';

iautoscroll                  :=false;
iautoscrollCOUNT             :=0;

iscrolltime__image           :=2;
iscrolltime__imageAnimated   :=iscrolltime__image * 2;
iscrolltime__text            :=10;
iscrolltime__midi            :=2;
iscrolltime__midiPlaying     :=10;
iscrolltime__other           :=2;

imidiLastTimeRef             :=0;
ibeatval                     :=0;
ibeatvalBass                 :=0;

//controls


//left area --------------------------------------------------------------------
xcols.style           :=bcLeftToRight;

with xcols.makecol(0,vLeftWidth,false) do
begin

ileftbar              :=xhigh.ntoolbar('');

with ileftbar do
begin

maketitle3('Files',false,false);

halign                :=2;//right align

normal                :=false;

add( 'ABOUT'      ,tepEdit20     ,0 ,'about' ,'About|Archive introduction panel' );
add( 'README'     ,tepREADME20   ,0 ,'readme' ,'README|Archive information panel' );
add( 'License'    ,tepLicense20  ,0 ,'license' ,'License|Archive license panel' );

add( ''     ,tepScrollDown20 ,0 ,'autoscroll' ,
 'Automatic Scroll|Automatically scroll down through the list of files.  The scroll rate varies depending on the file type:'+
 '|*'+
 '|* Image  '+k64(iscrolltime__image)        +'s  ('+k64(iscrolltime__imageAnimated)+'s when animated)'+
 '|* Sprite '+k64(iscrolltime__image)        +'s'+
 '|* Text   '+k64(iscrolltime__text)         +'s'+
 '|* Music  '+k64(iscrolltime__midiPlaying)  +'s  ('+k64(iscrolltime__midi)+'s when not playing)'+
 '|* Other  '+k64(iscrolltime__other)        +'s'+
 '');

end;

ilist                 :=client.nlistx('',
 'File List'+
 '|A list of available files in the archive.'+
 '|*|The file is viewed and / or played in the content viewer on the right.'+
 '|*|Each file can be extracted out to disk using one of the extraction methods under the "Archive Extraction Options" panel, located at the bottom of the right column.'+
 '',0,0,list__onitem);

ilist.ostyle          :=lslist;
ilist.bordersize      :=0;
ilist.oretainpos      :=true;
ilist.ocanshowmenu    :=true;
ilist.tagstr          :='list.doubleclick';
ilist.onumberFrom     :=0;
ilist.orows           :=true;
//ilistTab              :='L200;R80;';
ilistTab              :='';


with xhigh2 do
begin

nbreak(10);

imask                 :=nset('Available File Formats','File Formats|Toggle which file formats to view',0,0);

with imask do
begin

itemsperline          :=5;

end;

imaskbar              :=ntoolbar('');

with imaskbar do
begin

oscaleh               :=0.8;//06may2026
normal                :=false;

add('All Files' ,tepMask20,0,'maskmode.'+intstr32(mm_all)     ,xhelpval( 'maskmode.'+intstr32(mm_all)  ) );
add('Simple'    ,tepMask20,0,'maskmode.'+intstr32(mm_simple)  ,xhelpval( 'maskmode.'+intstr32(mm_simple)  ) );
add('Custom'    ,tepMask20,0,'maskmode.'+intstr32(mm_custom)  ,xhelpval( 'maskmode.'+intstr32(mm_custom)  ) );
add('Custom 2'  ,tepMask20,0,'maskmode.'+intstr32(mm_custom2) ,xhelpval( 'maskmode.'+intstr32(mm_custom2) ) );

end;

nbreak(10);

end;//xhigh2

end;


//right area--------------------------------------------------------------------

with xcols.makecol(1,vRightWidth,false) do
begin

irightbar             :=xhigh.ntoolbar('');

with irightbar do
begin

maketitle3('View',false,false);

normal                :=false;

add('Stop',tepStop20,0,'stop','Stop|Stop music playback');
add('Play',tepPlay20,0,'play','Play|Toggle music playback');

add('',tepDownward20,0,'vol.-','Volume|Decrease volume by 10%');
add('Vol 100',tepNone,0,'vol.100','Volume|Reset volume to 100%');
add('',tepUpward20,0,'vol.+','Volume|Increase volume by 10%');

add('',tepDownward20,0,'speed.-','Playback Speed|Decrease playback speed by 2%');
add('Speed 100',tepNone,0,'speed.100','Playback Speed|Reset playback speed to 100%');
add('',tepUpward20,0,'speed.+','Playback Speed|Increase playback speed by 2%');

add('Copy',tepCopy20,0,'copy','Copy to Clipboard|Copy the current image or text to Clipboard');
add('Copy All',tepCopy20,0,'copyall','Copy All to Clipboard|Copy the entire text document to Clipboard');

isep1:=addsep;

add('PNG',tepCopy20,0,'copy.b64.png',xhelpval('copy.b64.png'));
add('JPG',tepCopy20,0,'copy.b64.jpg',xhelpval('copy.b64.jpg'));
add('ICO',tepCopy20,0,'copy.b64.ico',xhelpval('copy.b64.ico'));
add('GIF',tepCopy20,0,'copy.b64.gif',xhelpval('copy.b64.gif'));

isep2:=addsep;

add('PNG',tepCopy20,0,'copy.array.png',xhelpval('copy.array.png'));
add('JPG',tepCopy20,0,'copy.array.jpg',xhelpval('copy.array.jpg'));
add('ICO',tepCopy20,0,'copy.array.ico',xhelpval('copy.array.ico'));
add('GIF',tepCopy20,0,'copy.array.gif',xhelpval('copy.array.gif'));

end;

//.text
itext                 :=nbwp('',nil);

with itext do
begin

oautoheight           :=true;
core.viewurl          :=false;
core.readonly         :=true;
olivewordcount        :=true;

end;

//.image
iimage                :=nimgview;

with iimage do
begin

oautoheight           :=true;
countcolors           :=true;
animate               :=true;

end;


pic8__init( ipiccore8 ,1 ,1 );
iflashref             :='';

ipic8                 :=tpre8.create( client ,nil ,@ipiccore8 );
ipic8.oautoheight     :=true;


imidilist             :=client.nlistx('','',0,0,midilist__onitem);
imidilist.otab        :=tbL100_L500;
imidilist.oscaleh     :=0.70;
imidilist.makepanel;


with xcolsh do//use "xcolsh"
begin

style       :=bcLeftToRight;

with makecol(1,50,false) do
begin

imidivol              :=mmidivol('Midi Volume','');

end;

with makecol(2,50,false) do
begin

imididevice           :=nmidi('Midi Device','');

end;

end;//xcolsh


with xhigh2 do
begin

//.ijump
ijumpbar              :=ntoolbar('');
ijumpbar.maketitle3('Playback Progress',false,false);
ijump                 :=njump('','Click and/or drag to adjust playback position',0,0);
ijump.status          :=1;


nbreak(10);
ibotbar               :=ntoolbar('');
nbreak(10);


with ibotbar do
begin
//xgrad;

normal                :=false;
maketitle3('Archive Extraction Options',true,false);
halign                :=1;

help:=
 'Archive Extraction Options'+
 '|The files contained within this interactive archive have been embedded directly into this app '+
 'for maximum security.  To access the files on your computer, they must be extracted '+
 'from this app and written to a folder on your computer''s storage device / disk drive.'+
 '|*|To extract the files in this archive select one of the methods listed in the panel below:'+
 '|*'+
 '|* View in temp folder (Recommended)'+
 '|* Save files to a folder...'+
 '|* Save a file to disk...'+
 '';


newline;
lsadd('View in temp folder',tepOpen20,0,'savefiles.totemp',
 'View in Temp Folder (Recommended)'+
 '|Extract all the files in the archive file list (left column) to a dedicated temporary folder in order to view and/or access them directly on your computer.'+
 '|*|There is no need to confirm during the extraction process as the files will be stored in an isolated temporary folder.'+
 '|*|Clean Up:|All files in the temporary folder will be automatically removed upon closing this app.'+
 '',-30);

lsadd('Save files to a folder...',tepSave20,0,'saveall.tofolder',
 'Save Files to Folder'+
 '|Extract all the files in the archive file list (left column) to a folder of your choice.'+
 '|*|If one or more files with the same name already exists in the destination folder then you will be prompted for overwrite confirmation before any file is extracted.'+
 '',-30);

lsadd('Save a file to disk...',tepSave20,0,'saveone.tofile',
 'Save File to Disk'+
 '|Save the currently selected file to disk with a name of your choice.'+
 '',-30);

with oinputcolorise do
begin

use         :=true;
minlen      :=0;
backTRUE    :=int__splice24( 0.75 ,0 ,cllime );
backFALSE   :=clred;
code        :=icTrue;

end;

end;

end;

end;

//bottom statusbar
i_type                          :=0;
i_filesize                      :=1;
i_dimensions                    :=2;
i_colors                        :=3;
i_bits                          :=3;
i_cells                         :=4;
i_fps                           :=6;
i_misc                          :=7;
i_archive                       :=8;
i_max                           :=8;

i_words                         :=i_filesize+1;
i_chars                         :=i_filesize+2;

i_tracks                        :=i_filesize+1;

i_cursorSize                    :=i_misc;

istatusbar                      :=xstatus2;
istatusbar.cellwidth[ i_max+1 ] :=1;

with istatusbar do
begin

cellhelp[ i_type     ]    :='Category|Descriptive style of the selected file';
cellhelp[ i_filesize ]    :='File Size|The uncompressed size of the selected file';
cellhelp[ i_archive  ]    :='Archive Information|The total number of files currently listed in the archive file list and their combined uncompressed size';

end;


//events
ileftbar.onclick      :=__onclick;
irightbar.onclick     :=__onclick;
ibotbar.onclick       :=__onclick;
imaskbar.onclick      :=__onclick;

ilist.ongetitem       :=list__onitem;
ilist.onclick         :=list__onclick;
ilist.ondbclick       :=list__ondbclick;

imidilist.ongetitem   :=midilist__onitem;
imidilist.ondbclick   :=list__ondbclick;

//.jump
ijump.onclick         :=__onclick;


//defaults
mid_settrimtolastnote( true );
mid_enhance( true );

gossgame__start;

game__setsubframes( true );

file__setmask('',mm_all);

file__viewDefault;

//start
if xstart then start;

end;

destructor tarchive.destroy;
begin
try

//clean temp folder
xcleantempfolder;

//controls
ipic8.disconnect;
freeobj(@isublist);
freeobj(@iinfvars);
str__free(@ilastfiledata);

//turn off temp cursor - 06may2026
cursor__untemp;

//self
inherited destroy;
if classnameis('tboxed') then track__inc(satOther,-1);

except;end;
end;

function tarchive.xhelpval(const x:string):string;
begin

result:=xhelpval2(x,true);

end;

function tarchive.xhelpval2(const x:string;const xfull:boolean):string;
begin

if      (x='copy.array.tea')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in 32 bit TEA format. Image data can be directly included into any Gossamer app source code.'
else if (x='copy.array.png')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in PNG format.'
else if (x='copy.array.jpg')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in JPEG format.'
else if (x='copy.array.gif')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in GIF format.'+xhelpval('gif.restriction')
else if (x='copy.array.ico')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in ICO format.'
else if (x='copy.b64.png')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format PNG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.jpg')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format JPEG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.ico')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format ICO. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.gif')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format GIF. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'+xhelpval('gif.restriction')

else if (x='gif.restriction') then result:='|*|'+'Format Restriction|The GIF image format can only store 2 mask values (on and off) and 256 colors. An image with subtle mask values, or 2 or more, or more than 256 colors may appear incorrectly.'

else if (x='maskmode.'+intstr32(mm_all)) then
   begin

   result:=
   'File List - All Files (Default)'+
   '|A straightforward option to list all the files contained within the archive.'+
   '';

   end

else if (x='maskmode.'+intstr32(mm_simple)) then
   begin

   result:=
   'File List - Simple (Interactive Mask)'+
   '|An easy-to-use interactive file listing selector.'+
   '|*|Select the file types you wish to list and un-select those you don''t.'+
   '|*|The file list will update automatically'+
   '|*|Note:|Un-selecting all the file types is identical to selecting them all, and will list every file in the archive.'+
   '';

   end

else if (x='maskmode.'+intstr32(mm_custom)) or (x='maskmode.'+intstr32(mm_custom2)) then
   begin

   result:=

   'File List - Custom Mask'+insstr(' 2',(x='maskmode.'+intstr32(mm_custom2)))+
   '|Use one or a series of complex masks to filter which files appear in the file list.'+
   '|*|Type one or more complex masks (e.g. *abc*.mid;*.jpg; ) per line, separating each with a semi-colon ";" and using no more '+
   'than 2 asterisks "*" per mask (e.g. *abc*;).'+

   '|*|Each file name in the list is compared against all the masks on one line.  If it matches just one mask, it passes down to the next line.'+
   '|*|If the file name passes every line to the last, then the file name will appear in the file list.'+

   insstr(
   '|*|To edit this custom mask, select this option, then select it again to display a pop-up text box.'
   ,xfull
   )+

   '';

   end

else
   begin
   result:='';
   //showbasic('Undefined help.val');
   end;

end;

procedure tarchive.master__stopAll;
begin

must__setmode( 0 ,true );

end;

function tarchive.auto__scrollMustNext:boolean;
begin

//defaults
result      :=false;

//get
if iautoscroll then
   begin

   inc( iautoscrollCOUNT );

   //disable and reset trigger event during mouse down events - 05may2026
   if gui.mousedown then
      begin

      iautoscrollCOUNT:=0;

      end;

   if (iautoscrollCOUNT>=auto__scrollCountTrigger) then
       begin

       iautoscrollCOUNT      :=0;

       result                :=true;

       end;

   end;

end;

function tarchive.auto__scrollCountTrigger:longint32;
begin

case ilastfiletype of
ft_image    :result:=low__aorb(iscrolltime__image,iscrolltime__imageAnimated,iimage.cells>=2);
ft_pic8     :result:=iscrolltime__image;
ft_midi     :result:=low__aorb(iscrolltime__midi,iscrolltime__midiPlaying,file__playing);
ft_text     :result:=iscrolltime__text;
else         result:=iscrolltime__other;
end;//case

//scale up by 10x
result      :=result*10;

end;

function tarchive.auto__scroll:boolean;
begin

result                :=iautoscroll;

end;

procedure tarchive.auto__setscroll(const x:boolean);
begin

iautoscroll           :=x;
iautoscrollCOUNT      :=0;

end;

function tarchive.must__mode:longint32;
begin

case ilastfiletype of
ft_image    :result:=iimage.mustmode;
ft_pic8     :result:=ipic8.mustmode;
else         result:=0;
end;//case

end;

procedure tarchive.must__setmode(const x:longint32;const xdisableScroll:boolean);
begin

if xdisableScroll then
   begin

   auto__setscroll( false );

   end;

case ilastfiletype of
ft_image    :iimage.mustmode    :=x;
ft_pic8     :ipic8.mustmode     :=x;
end;//case

end;

procedure tarchive.file__playSync;
begin


//play next and pos sync -------------------------------------------------------
if (ilastfiletype=ft_midi) then
   begin

   case file__playInfoInSync of
   true:ijump.setparams( mid_pos ,mid_len ,mid_speed );
   else ijump.setparams( 0 ,0 ,100 );
   end;//case

   if (mid_pos>=mid_len) and (not mid_seeking) and mid_playing then file__nextfile;

   end;


//auto-stop --------------------------------------------------------------------
if (ilastfiletype<>ft_midi) then
   begin

   if mid_playing then mid_stop;

   end;

end;

procedure tarchive.file__playToggle;
begin

case file__playing of
true:file__stop;
else file__play;
end;//case

end;

function tarchive.file__playInfoInSync:boolean;
begin

case ilastfiletype of
ft_midi:result:=strmatch(ilastplayfile,ilastfilename);
else    result:=false;
end;//case

end;

function tarchive.file__playing:boolean;
begin

case ilastfiletype of
ft_midi:result:=mid_playing;
else    result:=false;
end;//case

end;

procedure tarchive.file__play;
begin

case ilastfiletype of
ft_midi:begin

   case file__playInfoInSync of
   true:mid_play;
   else mid_playmidi( ilastfiledata );
   end;//case

   end;
end;//case

ilastplayfile         :=ilastfilename;

file__playSync;

end;

procedure tarchive.file__setplaypos(const xnewpos:longint);
begin

if not file__playing then file__play;

case ilastfiletype of
ft_midi:mid_setpos( xnewpos );
end;//case

end;

function tarchive.file__playlen:longint32;
begin

case ilastfiletype of
ft_midi:result:=mid_len;
else    result:=0;
end;//case

end;

function tarchive.file__playPos:longint32;
begin

case ilastfiletype of
ft_midi:result:=mid_pos;
else    result:=0;
end;//case

end;

function tarchive.file__canstop:boolean;
begin

case ilastfiletype of
ft_midi:result:=mid_canstop;
else    result:=false;
end;//case

end;

procedure tarchive.file__stop;
begin

case ilastfiletype of
ft_midi:mid_stop;
end;//case

file__playSync;

end;

function tarchive.file__tracks:longint32;
begin

case ilastfiletype of
ft_midi:result:=mid_tracks;
else    result:=0;
end;//case

end;

function tarchive.file__speed:longint32;
begin

case ilastfiletype of
ft_midi:result:=mid_speed;
else    result:=100;
end;//case

end;

procedure tarchive.file__setspeed(const x:longint32);
begin

case ilastfiletype of
ft_midi:mid_setspeed( x );
end;//case

end;

function tarchive.file__vol:longint32;
begin

case ilastfiletype of
ft_midi:result:=mid_vol;
else    result:=100;
end;//case

end;

procedure tarchive.file__setvol(const x:longint32);
begin

case ilastfiletype of
ft_midi:mid_setvol( x );
end;//case

end;

function tarchive.file__subTOfullindex(const sindex:longint):longint;
begin

if (sindex>=0) and (sindex<isublist.count) then result:=isublist.value[ sindex ]
else                                            result:=0;

end;

function tarchive.sfound(const n:string):boolean;
begin

result                :=iinfvars.found( n );

end;

function tarchive.sval(const n:string):string;
begin

result                :=iinfvars.s[ n ];

end;

procedure tarchive.ssetval(const n,v:string);
begin

iinfvars.s[ n ]       :=v;

end;

function tarchive.ival(const n:string):longint32;
begin

result                :=iinfvars.i[ n ];

end;

procedure tarchive.isetval(const n:string;const v:longint32);
begin

iinfvars.i[ n ]       :=v;

end;

function tarchive.file__excludeFilter:string;
begin

result:='*.res;*.ini;*.htm;*.html;*.__recent*;*.save-count;';

end;

function tarchive.file__type(const xfilename:string):longint;
var
   v:string;

   function m(const n:string):boolean;
   begin

   result   :=strmatch( v ,n );

   end;

begin

//get
v           :=io__readfileext_low( xfilename );

//decide
if      m('txt') or m('bwd') or m('bwp') or m('rtf') or
        m('bat') or m('log') or m('md')  or m('ini') then result:=ft_text

else if m('pic8')                                    then result:=ft_pic8

else if io__imageExtSupported(v)                     then result:=ft_image

else if m('mid') or m('midi') or m('rmi')            then result:=ft_midi

else if m('wav') or m('mp3')  or m('mp4')            then result:=ft_music

else                                                      result:=ft_binary;

end;

procedure tarchive.file__loadfile;
var
   xnewdata:pointer;
   fext,v,n,xnewfilename:string;
   i,flasttype,ftype,xtep,xdatalen,xorgSize:longint32;
   xcompressed:boolean;

   procedure fshow(const v:longint32);
   begin

   //show
   ipic8.visible      :=(v=ft_pic8);

   iimage.visible     :=(v=ft_image);
   itext.visible      :=(v=ft_text);

   imidilist.visible  :=(v=ft_midi);
   imidivol.visible   :=(v=ft_midi);
   imididevice.visible:=(v=ft_midi);
   ijumpbar.visible   :=(v=ft_midi);
   ijump.visible      :=(v=ft_midi);

   if (v=ft_midi) then imidilist.countx:=18;

   //update gui
   xupdatebuttons;
   gui.fullalignpaint;

   end;

   procedure ihelp(const n:string);//set image specific help

      function m(const x:string):boolean;
      begin

      result:=strmatch(x,n);

      end;

      procedure s(const xhelp:string);
      begin

      iimage.help:=xhelp;

      end;

   begin

   if      m('about')     then s('About|Archive introduction panel')
   else if m('readme')    then s('Read ME|Archive information panel')
   else if m('license')   then s('License|Archive license panel')
   else if m('cursor')    then
        begin

        s('');//set later
{//???????????????????
        s(
        'Cursor Preview'+
        '|The current image is a mouse cursor.  '+
        'Depending on your computer''s current mouse pointer size setting, your mouse pointer may appear larger or smaller than the cursor''s natural size.'+
        '');
{}//?????????????????
        end
   else begin

     s('Image Preview');

     end;
     
   end;

begin

//defaults
flasttype   :=ilastfiletype;


//sync mask --------------------------------------------------------------------

v           :='';

if (imaskmode=mm_custom) then
   begin

   v                  :=imaskCustom;

   end

else if (imaskmode=mm_custom2) then
   begin

   v                  :=imaskCustom2;

   end

else begin

   for i:=0 to pred(imask.count) do
   begin

   if imask.vals[ i ] then v:=v+imask.nams[ i ]+';';

   end;//i

   end;

file__setmask( v ,imaskmode );


//init -------------------------------------------------------------------------

file__info2( ilist.itemindex ,xnewdata ,xtep ,xdatalen ,xorgSize ,xcompressed ,xnewfilename );

//check

if strmatch(ilastfilename,xnewfilename) then exit;

//save previous settings -------------------------------------------------------

i                     :=file__subTOfullindex( file__findbyNameb( ilastfilename ) );
n                     :=intstr32(i)+'.';
ftype                 :=file__type( ilastfilename );

if (ftype=ft_text) then
   begin

   isetval( n + 'pos'           ,itext.cpos         );
   isetval( n + 'pos2'          ,itext.cpos2        );
   isetval( n + 'scrollv.px'    ,itext.core.vpos_px );
   isetval( n + 'scrollh'       ,itext.core.hpos    );

   end

else if (ftype=ft_midi) then
   begin

   end;


//load file and settings -------------------------------------------------------

i                     :=file__subTOfullindex( file__findbyNameb( xnewfilename ) );
n                     :=intstr32(i)+'.';
ftype                 :=file__type( xnewfilename );
fext                  :=io__readfileext_low( xnewfilename );

ilastfiletype         :=ftype;
ilastfilename         :=xnewfilename;
ilastfileext          :=fext;//06may2026
ilastfiledata.clear;
ilastfiledata.addrec( xnewdata ,xdatalen );

if xcompressed then low__decompress( @ilastfiledata );

must__setmode( 0 ,false );


if (ftype=ft_text) then
   begin


   itext.core.onefontname:=low__aorbstr(font_name1,font_name2,fext='txt');
   itext.core.onefontsize:=low__aorb(0,1,fext='txt');

   itext.ioset4( ilastfiledata ,'' ,ival( n + 'scrollv.px' ) ,-1 ,ival( n + 'scrollh' ) ,ival( n +'pos' ) ,ival( n +'pos2' ) ,false ,false );

   end

else if (ftype=ft_image) then
   begin

   //scale to fit screen for system images, else default mode - 05may2026
   iimage.fillStyle:=low__aorb(vfsDefault,vfsScreen,
      (
      strmatch(xnewfilename,isystem__about) or
      strmatch(xnewfilename,isystem__readme) or
      strmatch(xnewfilename,isystem__license)
      )
      );

   iimage.fadespeed:=low__aorb(5,100, ((flasttype<>ftype) or (iimage.fillStyle<>vfsDefault)) and (not ifirstfileload) );
   iimage.loadfromdata( @ilastfiledata ,true );

   //file specific help
   if      strmatch(xnewfilename,isystem__about    ) then ihelp('about'   )
   else if strmatch(xnewfilename,isystem__readme   ) then ihelp('readme'  )
   else if strmatch(xnewfilename,isystem__license  ) then ihelp('license' )
   else if cursor__formatSupported( xnewfilename   ) then ihelp('cursor'  )
   else                                                   ihelp('image'   );

   end

else if (ftype=ft_pic8) then
   begin

   pic8__fromdata( ipiccore8 ,ilastfiledata.text );
   pic8__renderinit( ipiccore8 );

   end

else if (ftype=ft_midi) then
   begin

   if (not ifirstfileload) and file__playing then file__play;

   end;


//show or hide controls
fshow( ftype );

//off
ifirstfileload        :=false;

end;

function tarchive.haveListIndex(const xmaskMode:longint32):boolean;
begin

result      :=sfound(intstr32(xmaskmode)+'.listindex');

end;

function tarchive.listIndex(const xmaskMode:longint32):longint32;
begin

result      :=ival(intstr32(xmaskmode)+'.listindex');

end;

function tarchive.listPos(const xmaskMode:longint32):longint32;
begin

result      :=ival(intstr32(xmaskmode)+'.listpos');

end;

procedure tarchive.setlistIndex(const xmaskMode,xval:longint32);
begin

isetval(intstr32(xmaskmode)+'.listindex',xval);

end;

procedure tarchive.setlistPos(const xmaskMode,xval:longint32);
begin

isetval(intstr32(xmaskmode)+'.listpos',xval);

end;

procedure tarchive.file__setmask(const xmask:string;const xmaskmode:longint32);
var
   xdata:pointer;
   lcount,p,xdatalen,xorgSize:longint32;
   xonce,xcompressed:boolean;
   xmaskREF,emask,xpathname:string;
   mcomplexMaskList,mlist:tdynamicstring;

   procedure mAdd(const n:string);
   begin

   //check -> keep them short
   if (low__len32(n)>6) then exit;

   //get
   if (mlist=nil) then mlist:=tdynamicstring.create;

   if (mlist.count<=31) and (mlist.find( 0 ,n ,false )<=-1) then
      begin

      mlist.value[ mlist.count ]:=n;

      end;

   end;

   function xfindSystemFile(const xbasename:string):string;
   var
      p:longint;
      v,n:string;

   begin

   //defaults
   result   :='';

   //get
   for p:=0 to max32 do
   begin

   //.in priority order
   case p of
   0:n:='rtf';
   1:n:='bwp';
   2:n:='bwd';
   3:n:='txt';
   4:n:='san';
   5:n:='gif';
   6:n:='png';
   7:n:='jpg';
   else break;
   end;//case

   v        :='.'+xbasename+'.'+n;

   if file__foundByName( v ) then
      begin

      result:=v;
      break;

      end;

   end;//p

   end;

   function filter__matchesMask:boolean;
   var
      p:longint32;

   begin

   //defaults
   result             :=false;

   //check
   if (xmask='') then
      begin

      result          :=true;
      exit;

      end;

   //get
   if (xmaskmode=mm_all) then
      begin

      result:=true;

      end

   else if (xmaskmode=mm_simple) then
      begin

      result          :=filter__matchlist(xpathname,xmask);

      end

   else if (xmaskmode>=mm_custom) then
      begin

      result          :=true;

      for p:=0 to pred(mcomplexMaskList.count) do
      begin

      if (mcomplexMaskList.value[p]<>'') and (not filter__matchlist(xpathname,mcomplexMaskList.value[p])) then
         begin

         result       :=false;
         break;

         end;

      end;//p

      end;

   end;

begin

//defaults
mlist                        :=nil;
mcomplexMaskList             :=nil;

try

//init
emask                        :=file__excludeFilter;
lcount                       :=0;
xonce                        :=(imask.count<=0);//done for first load -> scans entire archive for all file types on startup - 06may2026
xmaskREF                     :=intstr32(xmaskmode)+'|'+xmask;

//check
if (not xonce) and strmatch(ilastmaskREF,xmaskREF) then
   begin

   exit;

   end;

//init
ilastmaskREF                                     :=xmaskREF;
itotal_compressed_size                           :=0;
itotal_uncompressed_size                         :=0;

if (ilastmaskmode>=0) then
   begin

   setListIndex( ilastmaskmode,ilist.itemindex );
   setListPos  ( ilastmaskmode,ilist.pos       );

   end;
   
if (xmaskmode>=mm_custom) then
   begin

   mcomplexMaskList          :=tdynamicstring.create;
   mcomplexMaskList.text     :=xmask;

   end;

//get
{$ifdef gamecore}
for p:=0 to max32 do
begin

if archiveFiles.storage__findfile(p,xdata,xdatalen,xorgSize,xcompressed,xpathname) and
  (not io__hack_dangerous_filepath_deny_mask( xpathname ))            then//security check - prevent dangerous path chars
   begin

   //exclusion mask
   if (emask='') or (not filter__matchlist(xpathname,emask)) then
      begin

      //madd
      if xonce then
         begin

         mAdd( io__readfileext_low( xpathname ) );

         end;

      //inclusion mask
      if filter__matchesMask then
         begin

         isublist.value[ lcount ]:=p;
         inc( lcount );

         if (xdatalen>=1) then inc64( itotal_compressed_size   ,xdatalen );
         if (xorgSize>=1) then inc64( itotal_uncompressed_size ,xorgSize );

         end;

      end;

   end

else break;

end;//p
{$endif}

//set
isublist.setparams(lcount,lcount,0);
ilastmaskmode         :=xmaskmode;
ilist.countx          :=isublist.count;

if haveListIndex( xmaskmode ) then
   begin

   ilist.itemindex       :=listIndex( xmaskmode );
   ilist.pos             :=listPos  ( xmaskmode );

   end;

ilist.paintnow;


//sync on startup
if xonce then
   begin

   isystem__about     :=xfindSystemFile( 'about'   );
   isystem__aboutOK   :=(isystem__about<>''        );

   isystem__readme    :=xfindSystemFile( 'readme'  );
   isystem__readmeOK  :=(isystem__readme<>''       );

   isystem__license   :=xfindSystemFile( 'license' );
   isystem__licenseOK :=(isystem__license<>''      );

   end;


//mask list - once only
if xonce and (mlist<>nil) then
   begin

   //alpha sort
   mlist.sort( true );

   //get
   for p:=0 to pred(mlist.count) do
   begin

   imask.xset( p ,strup(mlist.svalue[p]) ,'*.'+mlist.svalue[p] ,'' ,true );//all on by default

   end;//p

   end;

except;end;

//free
if (mlist<>nil)            then freeobj(@mlist);
if (mcomplexMaskList<>nil) then freeobj(@mcomplexMaskList);

end;

procedure tarchive.file__viewDefault;
var
   xonce:boolean;

   procedure s(const n:string);
   var
      v:longint;

   begin

   if xonce and file__findByName( n ,v ) then
      begin

      xonce           :=false;
      ilist.itemindex :=v;

      end;

   end;

begin

//defaults
xonce       :=true;

s( istartFile      );

if isystem__aboutOK   then s( isystem__about    );
if isystem__readmeOK  then s( isystem__readme   );
if isystem__licenseOK then s( isystem__license  );

end;

procedure tarchive.file__view(const n:string);
begin

file__view2(n,false);

end;

procedure tarchive.file__view2(const n:string;const xshowError:boolean);
var
   i:longint;

begin

case file__findByName( n ,i ) of
true:ilist.itemindex:=i;
else begin

   if xshowError then gui.poperror('','File not found "'+n+'"');

   end;
end;//case

end;

function tarchive.file__count:longint32;
begin

result:=isublist.count;

end;

function tarchive.file__info(const xindex:longint;var xtep,xdatalen,xorgSize:longint32;var xpathname:string):boolean;
var
   xdata:pointer;
   xcompressed:boolean;

begin

result      :=file__info2( xindex ,xdata ,xtep ,xdatalen ,xorgSize ,xcompressed ,xpathname );

end;

function tarchive.file__info2(const xindex:longint;var xdata:pointer;var xtep,xdatalen,xorgSize:longint32;var xcompressed:boolean;var xpathname:string):boolean;

   procedure xnone;
   begin

   xdata              :=nil;
   xtep               :=tepEdit20;
   xdatalen           :=0;
   xorgSize           :=0;
   xcompressed        :=false;
   xpathname          :='';
   result             :=false;

   end;

   //clean-up any net-encoded filenames on-the-fly - 04may2026
   function xcleanPathname(const x:string):string;
   var
      dext:string;

   begin

   dext     :=io__readfileext_low( x );
   result   :=net__decodestrb( io__remlastext( x ) ) + insstr('.',dext<>'') + dext;

   end;

begin

{$ifdef gamecore}

if (xindex>=0) and (xindex<file__count) and archiveFiles.storage__findfile( file__subTOfullindex(xindex) ,xdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   result             :=true;
   xpathname          :=xcleanPathname( xpathname );
   xtep               :=tep__filetype202( xpathname ,tepEdit20 );

   end

else xnone;

{$else}

xnone;

{$endif}

end;

function tarchive.file__foundByName(const n:string):boolean;
var
   int1:longint;

begin

result      :=file__findByName( n ,int1 );

end;

function tarchive.file__findSystemFileByNameb(const n:string):longint;
begin

file__findSystemFileByName( n ,result );

end;

function tarchive.file__findSystemFileByName(const n:string;var xindex:longint):boolean;
begin//Note: implements a file mask change if required in order to load the requested system file

//find using current file list
result                :=file__findByName( n, xindex );

//if not found, default back to "all files" and try again
if not result then
   begin

   imaskmode          :=mm_all;

   file__setmask( '' ,imaskmode );

   result             :=file__findByName( n, xindex );

   end;

end;

function tarchive.file__findByNameb(const n:string):longint32;
begin

file__findByName( n ,result );

end;

function tarchive.file__findByName(const n:string;var xindex:longint):boolean;
var
   xdata:pointer;
   p,xdatalen,xorgSize:longint32;
   xcompressed:boolean;
   xpathname:string;

begin

//defaults
result      :=false;
xindex      :=0;

{$ifdef gamecore}

//find
for p:=0 to pred(file__count) do
begin

if archiveFiles.storage__findfile( file__subTOfullindex(p) ,xdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) and strmatch(n,xpathname) then
   begin

   result   :=true;
   xindex   :=p;

   break;

   end;

end;//p

{$endif}

end;

function tarchive.settingsREF(const xfull:boolean):string;
var
   li,lp,p:longint;

   procedure i32(const n:string;const v:longint32);
   begin

   result:=result+n+': '+intstr32(v)+#10;

   end;

   procedure b(const n:string;const v:boolean);
   begin

   result:=result+n+': '+bolstr(v)+#10;

   end;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//add values
i32('midi.device'    ,imididevice.val    );
i32('mask.set'       ,imask.val          );
i32('mask.mode'      ,imaskmode          );

for p:=0 to mm_max do
begin

if (p=imaskmode) then
   begin

   li       :=ilist.itemindex;
   lp       :=ilist.pos;

   end
else begin

   li       :=listIndex(p);
   lp       :=listPos  (p);

   end;

i32( intstr32(p) + '.lindex'  ,li );
i32( intstr32(p) + '.lpos'    ,lp );

end;//p

b  ('scroll'         ,auto__scroll       );
s  ('mask.custom'    ,low__tob64bstr( imaskCustom  ,0 ) );
s  ('mask.custom2'   ,low__tob64bstr( imaskCustom2 ,0 ) );
b  ('playing'        ,file__playing      );

end;

function tarchive.getsettings:string;
begin

result:=settingsREF(true);

end;

procedure tarchive.setsettings(x:string);
var
   a:tvars8;
   p,xmustIndex:longint32;

begin

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;
xmustindex            :=-1;

//get
imididevice.val       :=a.idef('midi.device',0);
imask.val             :=a.idef('mask.set',max32);
imaskmode             :=a.idef2('mask.mode',0,0,mm_max);
imaskCustom           :=low__fromb64str( a.s['mask.custom' ] );
imaskCustom2          :=low__fromb64str( a.s['mask.custom2'] );

for p:=0 to mm_max do
begin

setlistIndex( p ,a.i[intstr32(p)+'.lindex'] );
setlistPos  ( p ,a.i[intstr32(p)+'.lpos']   );

if (p=imaskMode) then
   begin

   xmustIndex         :=a.idef(intstr32(p)+'.lindex',-1);//-1=signals that "index" has no value and should not be used - 06may2026

   end;

end;//p

//load file / update mask
ilastmaskmode         :=-1;//prevent the "file__setmask()" proc from writing values to setListIndex/setListPos
file__loadfile;

//select file
if (xmustIndex>=0) and (ilist.itemindex<>xmustIndex) then
   begin

   ilist.itemindex    :=xmustIndex;
   file__loadfile;

   end;

//playing
if a.bdef('playing',false) then
   begin

   file__play;

   end;

//auto-scroll
auto__setscroll( a.bdef('scroll',false) );

except;end;

//free
freeobj(@a);

end;

procedure tarchive.__onclick(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 )
else if (sender is tbasicjump)  then xcmd('jump.mustpos');

end;

procedure tarchive.list__onclick(sender:tobject);
begin

master__stopAll;

end;

procedure tarchive.list__ondbclick(sender:tobject);
begin

//check
if not vidoubleclicks           then exit;

//get
if (sender is tbasicmenu)       then xcmd( (sender as tbasicmenu).tagstr );

end;

procedure tarchive.xcmd(xcode2:string);
label
   skipend;
var
   xresult:boolean;
   d:trawimage;
   v,e:string;
   xwas,i,v32:longint;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode2,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode2);
   end;

begin

//defaults
xresult :=true;
e       :=gecTaskfailed;
v       :='';
v32     :=0;
d       :=nil;

try

//get

if m('about') then
   begin

   master__stopAll;

   if isystem__aboutOK and file__findSystemFileByName( isystem__about ,i ) then ilist.itemindex:=i;

   end

else if m('readme') then
   begin

   master__stopAll;

   if isystem__readmeOK and file__findSystemFileByName( isystem__readme ,i ) then ilist.itemindex:=i;

   end

else if m('license') then
   begin

   master__stopAll;

   if isystem__licenseOK and file__findSystemFileByName( isystem__license ,i ) then ilist.itemindex:=i;

   end

else if m('autoscroll') then
   begin

   auto__setscroll( not auto__scroll );

   end

else if m('list.doubleclick') then
   begin

   file__playToggle;

   end

else if mv('jump.mustpos') then
   begin

   file__setplaypos( round32( (ijump.hoverpert/100) * file__playLen ) );

   end

else if m('stop') then
   begin

   file__stop;

   end

else if m('play') then
   begin

   file__playToggle;

   end

else if mv('vol.') then
   begin

   if (ilastfiletype=ft_midi) then
      begin

      if      (v='-')   then file__setvol( mid_vol - 10 )
      else if (v='+')   then file__setvol( mid_vol + 10 )
      else if (v='100') then file__setvol( 100 );

      end;

   end

else if mv('speed.') then
   begin

   if (ilastfiletype=ft_midi) then
      begin

      if      (v='-')   then v32:=file__speed - 2
      else if (v='+')   then v32:=file__speed + 2
      else if (v='100') then v32:=100;

      file__setspeed( frcrange32( v32 ,50 ,200 ) );

      end;

   end

else if m('copy') then
   begin

   case ilastfiletype of
   ft_image:begin

      if (iimage.cells>=2) then
         begin

         d:=misraw32(1,1);
         mis__copy(iimage.image32,d);
         mis__onecell( d );
         clip__copyimage( d );//one cell

         end

      else clip__copyimage( iimage.image32 );//one cell

      end;
   ft_text:itext.core.copy;
   end;//end

   end

else if m('copyall') then
   begin

   case ilastfiletype of
   ft_image:clip__copyimage( iimage.image32 );//image strip
   ft_text:itext.core.copyall;
   end;//end

   end

else if mv('copy.array.') then
   begin

   clip__copyimageAsArrayByte( iimage.image32 ,v ,false );

   end

else if mv('copy.b64.') then
   begin

   clip__copyimageAsBase64( iimage.image32 ,v ,false );

   end

else if m('saveone.tofile') then
   begin

   saveone__tofile;

   end

else if m('saveall.tofolder') then
   begin

   saveall__tofolder( false );

   end

else if m('savefiles.totemp') then
   begin

   saveall__tofolder( true );

   end

else if m('list.doubleclick') then
   begin

   ilist.paintnow;

   end

else if mv('maskmode.') then
   begin

   xwas               :=imaskmode;
   imaskmode          :=frcrange32(v32,0,mm_max);

   //edit
   if (xwas=imaskmode) then
      begin

      case imaskmode of
      mm_custom :gui.poptxt4( imaskCustom  ,0 ,true ,false ,true ,'Custom Mask'   , xhelpval2( 'maskmode.'+intstr32(imaskmode) ,false ) ,'','','',1,0.5);
      mm_custom2:gui.poptxt4( imaskCustom2 ,0 ,true ,false ,true ,'Custom Mask 2' , xhelpval2( 'maskmode.'+intstr32(imaskmode) ,false ) ,'','','',1,0.5);
      end;//case

      end;

   end

else begin

   //nil

   end;
skipend:

except;end;

//free
freeobj(@d);

//finish
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

procedure tarchive.dialog__suppressAllFormatOptions(x:boolean);
begin

case x of
true:ia__useroptions_suppress(true,'*');
else ia__useroptions_suppress_clear;
end;//case

end;

function tarchive.cansaveone:boolean;
begin

result:=(isublist.count>=1) and (ilastfilename<>'');

end;

procedure tarchive.saveone__tofile;
var
   daction,sname,df,dext,e:string;

begin

//stop all
master__stopAll;//05may2026

//check
if not cansaveone then exit;

//init
sname       :=io__extractfilename( ilastfilename );
dialog__suppressAllFormatOptions( true );

//prompt
df          :=io__asfolderNIL(io__extractfilepath( ilastsaveone_filename )) + sname;
dext        :=io__readfileext_low(sname);

if gui.popsave3( df ,dext ,'' ,'' ,daction ,true ,true ) then//last "true" permits the dialog to use unknown file type(s) - 05may2026
   begin

   ilastsaveone_filename     :=df;

   if not io__tofile64( df ,@ilastfiledata ,e ) then gui.popError('Save Failed',e);

   end;

//finish
dialog__suppressAllFormatOptions( false );

end;

function tarchive.cansaveall:boolean;
begin

result:=(isublist.count>=1);

end;

procedure tarchive.saveall__tofolder(const xuseTempFolder:boolean);
label
   redo,skipCheck,skipend;

var
   pdata:pointer;
   fdata:tstr8;
   df,dfolder,fpathname,e:string;
   xreplaceMode,xfileExistsCount,xtep,xdatalen,xorgSize,fsaveCount,fskipCount,ferrorCount,i,p,xfileCount:longint32;
   fbytes,xstatusref:longint64;
   xcheckOnly,xcompressed:boolean;

   procedure dstatus;
   begin

   sysstatus_settext(1,'File'+#9+fpathname);
   sysstatus_settext(2,'Item'+#9+k64(fsaveCount)+' / '+k64(xfileCount));
   sysstatus_settext(3,'Errors'+#9+k64(ferrorCount));
   sysstatus_settext(4,'Skipped'+#9+k64(fskipCount));
   sysstatus_settext(5,'Size'+#9+low__mbAUTO2(fbytes,3,true));
   sysstatus_setpert(low__percentage64(p+1,xfilecount));
   msset(xstatusref,100);

   end;

   procedure dstart;
   begin

   gui.xstatusstart(2.0,6);
   gui.xstatustab(tbDefault);
   sysstatus_settext(0,'Folder'+#9+dfolder);
   sysstatus_settext(1,'File'+#9+'');
   sysstatus_settext(2,'Item'+#9+'');
   sysstatus_settext(3,'Errors'+#9+'');
   sysstatus_settext(4,'Skipped'+#9+'');
   sysstatus_settext(5,'Size'+#9+'');

   case xcheckOnly of
   true:gui.xstatus(0,'Check files in folder...');
   else gui.xstatus(0,'Writing files to folder...');
   end;//case

   msset(xstatusref,100);

   end;

begin

//stop all
master__stopAll;//05may2026

//defaults
fdata                 :=nil;
xfileExistsCount      :=0;
xreplaceMode          :=rm_replaceall;//default mode

//check
if not cansaveall then exit;

try

//prompt
redo:

case xuseTempFolder of
true:xcleantempfolder;//clean previous files

else begin

   if not gui.popfolder2(ilastsaveall_folder,'*','',true,true) then exit;

   //ensure selected folder exists
   if not io__folderexists( ilastsaveall_folder ) then
      begin

      gui.poperror('','Folder not found');

      goto redo;

      end;

   end;

end;//case

case xuseTempFolder of
true:dfolder         :=xtempfolder( true );
else dfolder         :=ilastsaveall_folder;
end;//case

//init
xfileCount           :=file__count;
fsaveCount           :=0;
ferrorCount          :=0;
fskipCount           :=0;
fdata                :=str__new8;
fbytes               :=0;

//get
for i:=0 to 1 do
begin

xcheckOnly            :=(i=0);

dstart;//start status

if xcheckOnly and xuseTempFolder then
   begin

   //temp folder does not need to perform file name overwrite checking
   goto skipCheck;

   end;

//.prompt to replace existing files
if (not xcheckOnly) and (not xuseTempFolder) and (xfileExistsCount>=1) then
   begin

   gui.xstatusstop;

   xreplaceMode       :=xpromptReplaceAll(

    rcode+
    'There are '+k64( xfileExistsCount )+' file'+insstr('s',xfileExistsCount<>1)+' in the destination folder '+
    'with the same name.  Do you wish to replace all the existing files with those from the archive?  '+

    '');

   //cancelled
   if (xreplaceMode=rm_cancel) then goto skipend;

   //re-show
   dstart;

   end;


//.file list
for p:=0 to pred(xfileCount) do
begin

if (p=0) or msok(xstatusref)  then dstatus;
if gui.xstatustopped          then goto skipend;


if file__info2( p ,pdata ,xtep ,xdatalen ,xorgSize ,xcompressed ,fpathname ) then
   begin


   //init ----------------------------------------------------------------------

   df                 :=dfolder + fpathname;


   //check if file(s) already exist --------------------------------------------

   if xcheckOnly then
      begin

      if io__fileexists( df ) then
         begin

         inc( xfileExistsCount );

         end;

      end

   //write files ---------------------------------------------------------------

   else
      begin

      if (xreplaceMode=rm_replaceAll) or (not io__fileexists( df )) then
         begin

         fdata.clear;
         fdata.addrec( pdata ,xdatalen );

         if xcompressed then low__decompress( @fdata );

         //set
         if io__tofile64( df ,@fdata ,e ) then
            begin

            inc( fsaveCount );
            inc64( fbytes ,fdata.len32 );

            end
         else begin

            inc( ferrorCount );

            end;

         end

      else inc( fskipCount );

      end;


   end;//file__info2

end;//p

skipCheck:

end;//i

skipend:
except;end;

try

//status stop
gui.xstatusstop;

//popstatus
if (fsaveCount>=1) or (fskipcount>=1) or (ferrorCount>=1) then
   begin

   gui.popStatus(

    k64(fsaveCount)+' file'+insstr('s',fsaveCount<>1)+' written'+

    insstr(' with',(ferrorCount>=1) or (fskipCount>=1))+

    insstr( #32+k64(ferrorCount)+' error'+insstr('s',ferrorCount<>1) ,(ferrorCount>=1) )+

    insstr( ' and',(ferrorCount>=1) and (fskipCount>=1) )+

    insstr( #32+k64(fskipCount)+' skipped' ,(fskipCount>=1) )+

    '',3 );

   end;

//auto-show folder
if ((fsaveCount>=1) or (fskipCount>=1)) and io__folderexists( dfolder ) then
   begin

   runlow( dfolder ,'' );

   end;

except;end;

//free
str__free(@fdata);

end;

function tarchive.xtempfolder(const xautocreate:boolean):string;
begin

result      :=app__folder2('contents',xautocreate);

end;

procedure tarchive.xcleantempfolder;
var
   dfolder:string;
   flist:tdynamicstring;
   p:longint;

begin

//defaults
flist       :=nil;

try

//init
dfolder     :=xtempfolder( false );
flist       :=tdynamicstring.create;


//delete files -----------------------------------------------------------------
io__filelist1( flist ,false ,true ,dfolder ,'*' ,'' );

for p:=0 to pred(flist.count) do io__remfile( dfolder + flist.value[ p ] );


//delete empty folders ---------------------------------------------------------
io__folderlist2( flist ,false ,true ,dfolder ,'*' ,'' );

for p:=0 to pred(flist.count) do io__deletefolder( dfolder + flist.value[ p ] );


//finalise -> remove temp folder itself
io__deletefolder( dfolder );


except;end;

//free
freeobj(@flist);

end;

procedure tarchive.setcelltext(xindex:longint;xtext:string);
var
   dw:longint;

begin

//get
if      (xindex=i_bits)      then dw:=80
else if (xindex=i_misc)      then dw:=120
else if (xindex=i_archive)   then dw:=320
else                              dw:=130;

//set
istatusbar.celltext  [ xindex ]       :=xtext;
istatusbar.cellwidth [ xindex ]       :=insint(dw,xtext<>'');

end;

procedure tarchive.xupdatebuttons;
const
   xspace='  ';

var
   p,fc,ft,v32,v:longint;
   vs:string;
   bol1,xmustRealign:boolean;

   function mv(const xfullname,xpartname:string):boolean;
   begin
   result:=strm(xfullname,xpartname,vs,v32);
   end;

   procedure xhidecellsfrom(const xfrom:longint);
   var
      p:longint;

   begin

   for p:=xfrom to i_max do celltext[ p ]:='';

   celltext[ i_archive ] :=
    low__mbAUTO2( itotal_uncompressed_size ,2 ,true ) +
    ' and '+
    k64( file__count )+' file'+insstr('s',file__count<>1)+
    ' listed for archive';

   end;

begin


//init -------------------------------------------------------------------------

ft                              :=ilastfiletype;
fc                              :=file__count;
xmustRealign                    :=false;


//leftbar ----------------------------------------------------------------------

with ileftbar do
begin

bvisible2['about']              :=isystem__aboutOK;
bmarked2 ['about']              :=isystem__aboutOK   and strmatch( ilastfilename ,isystem__about );

bvisible2['readme']             :=isystem__readmeOK;
bmarked2 ['readme']             :=isystem__readmeOK  and strmatch( ilastfilename ,isystem__readme );

bvisible2['license']            :=isystem__licenseOK;
bmarked2 ['license']            :=isystem__licenseOK and strmatch( ilastfilename ,isystem__license );

bflash2  ['autoscroll']         :=auto__scroll;
bmarked2 ['autoscroll']         :=auto__scroll;

end;


//rightbar ---------------------------------------------------------------------

with irightbar do
begin

//.stop and play
bvisible2['stop']               :=(ft=ft_midi);
benabled2['stop']               :=(ft=ft_midi) and file__canstop;

bvisible2['play']               :=(ft=ft_midi);
benabled2['play']               :=(ft=ft_midi);
bmarked2 ['play']               :=(ft=ft_midi) and file__playing;
bflash2  ['play']               :=(ft=ft_midi) and file__playing;

//.volume
bvisible2['vol.-']              :=(ft=ft_midi);
benabled2['vol.-']              :=(ft=ft_midi) and (file__vol>0);

bvisible2['vol.+']              :=(ft=ft_midi);
benabled2['vol.+']              :=(ft=ft_midi) and (file__vol<100);

bvisible2['vol.100']            :=(ft=ft_midi);
benabled2['vol.100']            :=(ft=ft_midi) and (file__vol<>100);

//.speed
bvisible2['speed.-']            :=(ft=ft_midi);
benabled2['speed.-']            :=(ft=ft_midi) and (file__speed>50);

bvisible2['speed.+']            :=(ft=ft_midi);
benabled2['speed.+']            :=(ft=ft_midi) and (file__speed<200);

bvisible2['speed.100']          :=(ft=ft_midi);
benabled2['speed.100']          :=(ft=ft_midi) and (file__speed<>100);

//.copy
bvisible2['copy']               :=(ft=ft_image) or (ft=ft_text);
benabled2['copy']               :=(ft=ft_image) or ( (ft=ft_text) and itext.core.cancopy );

case ft of
ft_image:bhelp2['copy']         :='Copy|Copy image to Clipboard';
ft_text:bhelp2['copy']          :='Copy|Copy selected text to Clipboard';
end;//case

//.copy all
bvisible2['copyall']            :=(ft=ft_image) or (ft=ft_text);
benabled2['copyall']            :=(ft=ft_text) or ( (ft=ft_image) and (iimage.cells>=2) );

case ft of
ft_image:bhelp2['copyall']      :='Copy All|Copy all image cells to Clipboard';
ft_text :bhelp2['copyall']      :='Copy All|Copy all text to Clipboard';
end;//case

//.other
bvisible[ isep1 ]               :=(ft=ft_image);
bvisible2['copy.array.png']     :=(ft=ft_image);
bvisible2['copy.array.jpg']     :=(ft=ft_image);
bvisible2['copy.array.gif']     :=(ft=ft_image);
bvisible2['copy.array.ico']     :=(ft=ft_image);

bvisible[ isep2 ]               :=(ft=ft_image);
bvisible2['copy.b64.png']       :=(ft=ft_image);
bvisible2['copy.b64.jpg']       :=(ft=ft_image);
bvisible2['copy.b64.gif']       :=(ft=ft_image);
bvisible2['copy.b64.ico']       :=(ft=ft_image);

end;


//botbar -----------------------------------------------------------------------

with ibotbar do
begin

benabled2['savefiles.totemp']     :=cansaveall;
benabled2['saveall.tofolder']     :=cansaveall;
benabled2['saveone.tofile'  ]     :=cansaveone;

end;


//maskbar ----------------------------------------------------------------------

with imaskbar do
begin

for p:=0 to mm_max do
begin

bmarked2 ['maskmode.'+intstr32(p)]     :=(p=imaskmode);
//bflash2  ['maskmode.'+intstr32(p)]     :=(p=imaskmode);

end;//p

end;


//statusbar --------------------------------------------------------------------

case ft of
ft_text  :vs:='Text';
ft_image :vs:='Image';
ft_pic8  :vs:='Sprite';
ft_midi  :vs:='Music';
else      vs:='Binary';
end;//case

celltext[ i_type   ]              :=vs;

celltext[ i_filesize   ]          :=low__mbAUTO2( ilastfiledata.len32 ,2 ,true );

if (ilastfiletype=ft_image) then
   begin

   celltext[ i_dimensions ]       :=k64(iimage.width)+'w x '+k64(iimage.height)+'h';
   celltext[ i_colors     ]       :=k64(iimage.colors)+' color'+insstr('s',iimage.colors<>1);

   celltext[ i_cells ]            :=k64(iimage.cells)+' cell'+insstr('s',iimage.cells<>1);

   celltext[ i_bits ]             :=k64(iimage.bpp)+' bit';


   case (iimage.cells<=1) or (iimage.delay<1) of
   true:celltext[ i_fps ]         :='static';
   else celltext[ i_fps ]         :=curdec(1000/frcmin32(iimage.delay,1),2,false)+' fps';
   end;


   if cursor__formatSupported( ilastfileext ) then
      begin

      vs                        :=k64(frcmin32( (100*cursor__size) div frcmin32(largest32(iimage.width,iimage.height),1) ,0))+'%';

      iimage.help               :='Cursor Preview|Your mouse pointer is set to show this cursor at '+vs;

      celltext[i_cursorSize]    :='cursor at '+vs;
      xhidecellsfrom( i_cursorSize + 1);

      end

   else xhidecellsfrom( i_fps + 1);

   end

else if (ilastfiletype=ft_text) then
   begin

   v                              :=itext.wordcount;
   celltext[ i_words ]            :=k64( v )+' word'+insstr('s',v<>1);

   v                              :=frcmin32(itext.core.data.len32-1,0);
   celltext[ i_chars ]            :=k64( v )+' char'+insstr('s',v<>1);

   xhidecellsfrom( i_chars + 1);

   end

else if (ilastfiletype=ft_midi) then
   begin

   v                         :=low__aorb(-1,file__tracks,file__playInfoInSync);
   celltext[ i_tracks ]      :=low__aorbstr('-',k64(v)+' track'+insstr('s',v<>1),v>=0);

   xhidecellsfrom( i_tracks + 1);

   end
else begin

   xhidecellsfrom( i_filesize + 1);

   end;


//other ------------------------------------------------------------------------

bol1                  :=(imaskmode=mm_simple);
if (bol1<>imask.visible) then
   begin

   imask.visible      :=bol1;
   xmustRealign       :=true;

   end;

   
//xmustRealign
if xmustRealign then
   begin

   gui.fullalignpaint;
   
   end;

end;

procedure tarchive.file__prevfile;
begin

must__setmode(0,false);//turn off

if (ilist.itemindex>0)                 then ilist.itemindex:=ilist.itemindex-1
else                                        ilist.itemindex:=pred(ilist.count);

end;

procedure tarchive.file__nextfile;
begin

must__setmode(0,false);//turn off

if (ilist.itemindex<pred(file__count)) then ilist.itemindex:=ilist.itemindex+1
else                                        ilist.itemindex:=0;

end;

function tarchive.cursor__formatSupported(const x:string):boolean;

   function m(const n:string):boolean;
   begin

   result:=strmatch(n,x);

   end;

begin

result:=(x<>'') and ( m('ico') or m('cur') or m('ani') );

end;

procedure tarchive.cursor__preview;
var
   xok:boolean;


begin

//get
xok         :=
            (gui.control__fastfindxyb( gui.mousemovexy.x ,gui.mousemovexy.y )=iimage.coreindex) and
            cursor__formatSupported(ilastfileext);

//get
if low__setstr(icursorpreviewREF,bolstr(xok)+'|'+ilastfilename) then
   begin

   case xok of
   true:cursor__usetemp( @ilastfiledata );
   else cursor__untemp;
   end;//case

   end;

end;

procedure tarchive._ontimer(sender:tobject);
const
   vroller_max        =255;
   vroller_min        =60;
   vroller_step       =5;
   vroller_power      =1.0;
   vroller_idleUP     =false;
   vidle_period       =10000;//10s

begin
try

//pic8 - cycle flashers
if (ilastfiletype=ft_pic8) then game__flashcycle(false);

//midi beat flash
if (ilastfiletype=ft_midi) then midi__beatFlash;

//.itimerfast
if (ms64>=itimerfast) then
   begin

   //iroller255 ----------------------------------------------------------------

   //.up
   if irollerUP then
      begin

      inc(iroller255,vroller_step);

      if (iroller255>vroller_max) then
         begin

         iroller255   :=vroller_max;

         if (not vroller_idleUP) or (low__inputidle>=vidle_period) then
            begin

            irollerUP :=false;

            end;

         end;
      end

   //.down
   else begin

      dec(iroller255,vroller_step);

      if (iroller255<vroller_min) then
         begin

         iroller255   :=vroller_min;

         if vroller_idleUP or (low__inputidle>=vidle_period) then
            begin

            irollerUP :=true;

            end;

         end;

      end;

   //.repaint to reflect subtle change in background tint
   if low__setint( ibotbar.oinputcolorise.backTRUE ,int__splice24( (1-vroller_power) + ((iroller255/255)*vroller_power) ,0 ,vinormal.highlight ) ) then
      begin

      ibotbar.paintnow;
      app__turbo;

      end;

   //reset
   itimerfast:=add64( ms64 ,30 );

   end;


//.itimer100
if (slowms64>=itimer100) then
   begin


   //cusor preview -------------------------------------------------------------

   cursor__preview;


   //autoscroll ----------------------------------------------------------------

   if auto__scrollMustNext then
      begin

      file__nextfile;

      end;


   //pic8 - paint --------------------------------------------------------------

   if (ilastfiletype=ft_pic8) and pic8__mustpaint(ipiccore8,iflashref) then
      begin

      app__turbo;

      pic8__renderinit( ipiccore8 );
      ipic8.paintnow;

      end;


   //load new file -------------------------------------------------------------
   file__loadfile;

   //play sync
   file__playSync;

   //mustmode => left/right clicks
   if (must__mode<0) then
      begin

      auto__setscroll( false );
      file__prevfile;

      end
   else if (must__mode>0) then
      begin

      auto__setscroll( false );
      file__nextfile;

      end;

   
   //reset ---------------------------------------------------------------------
   itimer100:=add64( slowms64 ,100 );

   end;

//.itimer250
if (slowms64>=itimer250) then
   begin

   //midi list
   if (ilastfiletype=ft_midi) then
      begin

      imidilist.paintnow;

      end;

   //flash paints
   if low__setbol(ilastflash,sysflash) then
      begin

      ilist.paintnow;

      end;

   //reset
   itimer250:=add64( slowms64 ,250 );

   end;


//.itimer500
if (slowms64>=itimer500) then
   begin

   //update buttons etc
   xupdatebuttons;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

except;end;
end;

function tarchive.list__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   xdatalen,xorgSize:longint;

begin

//defaults
result      :=true;
xtab        :=ilistTab;

//get
file__info( xindex ,xtep ,xdatalen ,xorgSize ,xcaption );

if (ilistTab<>'') then xcaplabel:=xcaption+#9+low__kbb(xdatalen,2,true)
else                   xcaplabel:=xcaption;

end;

function tarchive.midilist__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   int1,xfileindex,xfilecount,xfilesize,xpos,xlen,xspeed,spos,slen,strim:longint;
   xerrmsg,str1:string;
   xsyncOK,bol1,xhavefile:boolean;

   function xfilter(x,xdef:string):string;
   begin
   if xhavefile then result:=x else result:=xdef;
   end;

   function s(xcount:longint):string;
   begin
   result:=insstr('s',xcount<>1);
   end;

begin
result:=true;

try
//init
xsyncok        :=file__playInfoInSync;
xtep           :=tepFNew20;
xtepcolor      :=clnone;
xcaption       :='';
xcaplabel      :='';
xhelp          :='';
xcode2         :='';
xcode          :=0;
xshortcut      :=aknone;
xindent        :=0;//xindex*5;
xflash         :=false;//25mar2021
xenabled       :=true;
xtitle         :=false;//(xindex=3);
xsep           :=false;
xhavefile      :=xsyncOK and (ilastfiledata.len32>=1);
xlen           :=1;//safe default
xpos           :=0;
xspeed         :=100;
slen           :=1;//safe default
spos           :=0;
strim          :=0;
xfilesize      :=str__len32( @ilastfiledata );

if xhavefile then
   begin

   xlen      :=frcmin32(mid_len,1);
   xpos      :=mid_pos;
   xspeed    :=frcmin32(mid_speed,1);

   //speed adjusted values
   slen      := frcmin32(trunc( xlen*(100/xspeed) ),1);
   spos      := trunc( (xpos/xlen)*slen );
   strim     := trunc( (mid_lenfull-mid_len)*(100/xspeed) );
   end;

xfileindex   :=ilist.itemindex;
xfilecount   :=file__count;


//.info
case xindex of
//technical
0:begin
   xtep:=tepnone;
   xcaption:='Technical';
   xtitle:=true;
   end;

1:begin

   int1:=mid_handlecount;

   case mid_deviceactive of
   true:str1:='Online' +insstr('  ( '+k64(int1)+' device'+insstr('s',int1<>1)+' in use ) ',int1>=1);
   else str1:='Offline'+insstr(' - failed to open midi device', mid_playing and (mid_outdevicecount>=1) );
   end;//case

   xcaption:='Device Status'+#9+str1;

   end;

2:begin

   int1:=mid_outdevicecount;

   case (int1>=1) of
   true:str1:=k64(int1)+' midi playback device'+s(int1)+' present';
   else str1:='ERROR: No midi playback devices present - no sound';
   end;//case

   xcaption:='Device Count'+#9+str1;

   end;

3:begin

   xerrmsg  :=insstr(' ( '+mid_timermsg+' )',mid_timercode<>0);
   xcaption :='Resolution'+#9+curdec(mid_msrate,2,false)+' ms / '+curdec(mid_mspert100,1,false)+'%'+xerrmsg;//15aug2025, 05mar2022

   end;

4:xcaption:='Name'+#9+xfilter(io__extractfilename(ilastfilename),'-');
5:xcaption:='Folder'+#9+strdefb(io__extractfilepath(ilastfilename),'( Internal Folder )');
6:xcaption:='Size'+#9+xfilter(low__b(xfilesize,true)+'  ( '+low__mb(xfilesize,true)+' )','-');
7:xcaption:='File'+#9+xfilter(k64(1+xfileindex)+' / '+k64(xfilecount),'-');

8:begin
   int1:=mid_format;
   case int1 of
   0:str1:='Single Track';
   1:str1:='Multi-Track';
   else str1:='Not Supported';
   end;
   xcaption:='Format'+#9+xfilter(intstr32(int1)+' / '+str1,'-');
   end;

9:xcaption:='Tracks'+#9+xfilter(k64(mid_tracks),'-');
10:xcaption:='Messages'+#9+xfilter(k64(mid_msgssent)+' / '+k64(mid_msgs),'-');

//playback
11:begin
   xtep:=tepnone;
   xcaption:='Playback';
   xtitle:=true;
   end;
12:xcaption:='Elapsed'+#9+low__uptime(spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
13:xcaption:='Remaining'+#9+low__uptime(slen-spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
14:xcaption:='Total'+#9+low__uptime(slen,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32)+insstr(' ( '+curdec( (100/xspeed)*100 ,1,true)+'% )',slen<>xlen);
15:xcaption:='Trim'+#9+low__aorbstr('Off', low__uptime(strim,false,false,false,true,ijump.oms,#32)+' of silence', mid_trimtolastnote );
16:xcaption:='Speed'+#9+k64(mid_speed)+'%';
17:xcaption:='State'+#9+low__aorbstr('Stopped','Playing',mid_playing);
else
   begin
   xtep:=tepnone;
   end;
end;//case
except;end;
end;

procedure tarchive.midi__beatFlash;
var
   xbass:boolean;
   dcount,dtotal,dcount3,dtotal3,xchannel,xnote,vcount,vtotal:longint;
   vave,vave3,vaved,vaveBass:double;
   vtime,v64:comp;
   xinfo:tmidinote;

   function xave(xtotal,xcount:longint):double;
   begin

   result:=frcrangeD64( ( xtotal/frcmin32(xcount,1) )*(1/127), 0, 1);

   end;

begin
try

//animate "playback bar" and side "volume bars"
if mid_playing then
   begin

   //init
   v64    :=ms64;

   vtime  :=0;
   vcount :=0;
   vtotal :=0;

   //.drums
   dcount  :=0;
   dtotal  :=0;

   dcount3 :=0;
   dtotal3 :=0;

   //get
   //.channels
   for xchannel:=0 to 15 do
   begin

   xbass   :=mid_voiceisBass( mmsys_mid_voiceindex[ xchannel ] );

   //.notes
   for xnote:=0 to 127 do if mid_trackinginfo(xchannel,xnote,xinfo) and (xinfo.volOUT>=1) and (xinfo.timeOUt>=v64) then
      begin

      //normal notes
      inc(vcount);
      inc(vtotal,xinfo.volOUT);

      //bass.average notes
      if xbass then
         begin

         inc(dcount3);
         inc(dtotal3,xinfo.volOUT);

         end;

      //drum notes
      if (xchannel=9) then
         begin

         inc(dcount,1);
         inc(dtotal,xinfo.volOUT);

         end;

      end;//xnote

   end;//xchannel


   //set
   vave     :=xave(vtotal,vcount);
   vave3    :=xave(dtotal3,dcount3);
   vaved    :=xave(dtotal,dcount);


   if low__setcmp(imidiLastTimeRef,vtime) then//new notes bring new times -> detect new notes and pulse the bars up/down by 25% - 03sep2025
      begin

      if (vave>=1)  then vave:=(vave*0.75)   else vave:=frcrangeD64(1.25*vave,0,1);
      if (vave3>=1) then vave3:=(vave3*0.75) else vave3:=frcrangeD64(1.25*vave3,0,1);
      if (vaved>=1) then vaved:=(vaved*0.95) else vaved:=frcrangeD64(1.05*vaved,0,1);

      end;

   vaveBass        :=frcrangeD64( vaved + ( vave3*0.3 ) ,0,1);
   ibeatval        :=frcrangeD64( (( vave     + (ibeatval     *5) ) / 6), 0, 1);//choke values 0..1 to avoid accidental numerical runaway overflow
   ibeatvalBass    :=frcrangeD64( (( vaveBass + (ibeatvalBass *2) ) / 3), 0, 1);//faster drift down for drums

   //.immediate up stroke
   if (vaveBass>ibeatvalBass) then ibeatvalBass:=vaveBass;


   //fast timer
   app__turbo;

   end
else
   begin

   ibeatval        :=0;
   ibeatvalBass    :=0;

   end;


//render.rate - 01feb2026
if (ms64>=imidiFastTimer) then
   begin

   //jump bar animation
   if true then
      begin

      ijump.flashval  :=ibeatval;
      ijump.flashval9 :=ibeatvalBass;

      case 1 of
      0:ijump.power    :=0.20;
      1:ijump.power    :=0.45;
      else ijump.power :=1.00;
      end;//case

      end
   else
      begin

      ijump.flashval  :=0;
      ijump.flashval9 :=0;

      end;


   //reset
   imidiFastTimer:=add64(ms64,30);

   end;

except;end;
end;

function tarchive.xpromptReplaceAll(const xmsg:string):longint;
var
   a:tbasicscroll;
   da:twinrect;
   dw,dh,xpreviousfocus:longint;
   xpreviouscontrol:tbasiccontrol;
begin
//defaults
result                :=rm_cancel;
a                     :=nil;

try
//init
xpreviousfocus        :=gui.winfocus;
xpreviouscontrol      :=gui.focuscontrol;
//init
//was:dw:=400;dh:=200;low__winzoom2(dw,dh,50,50);//17mar2021
gui__scale4(1.1 ,500 ,200 ,50 ,50 ,dw ,dh );//11dec2025

da.left               :=(gui.width-dw) div 2;
da.top                :=(gui.height-dh) div 2;
da.right              :=da.left+dw-1;
da.bottom             :=da.top+dh-1;

//get
a                     :=gui.ndlg(da,false);
a.oborderstyle        :=bsSystem50;
a.static              :=true;
a.xhead.caption       :='Replace All';
a.xhead.tep           :=tepQuery24;
a.xhelp;
a.xgrad;//09dec2024
a.nbwp('',str__newaf8b(xmsg)).makeviewonly;

with a.xtoolbar2 do
begin

cadd(ntranslate('Yes - Replace all files'),tepYes20,rm_replaceall,scdlg,rthtranslate('Replace all files'),0);
cadd(ntranslate('No - Skip all existing files'),tepClose20,rm_skipall,scdlg,rthtranslate('Skip existing files'),0);
cadd(ntranslate('Cancel - Do nothing'),tepStop20,rm_cancel,scdlg,rthtranslate('Cancel'),-120);

end;//with

//set
if gui.xshowwait(a,xpreviouscontrol,xpreviousfocus) then result:=a.ocode;

except;end;

//free
freeobj(@a);

end;



//## tapp ######################################################################
constructor tapp.create;
begin


if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//win__make_gosswin2_pas;app__halt;


//prevent app from closing immediately -> we control the shutdown process
app__closepaused:=true;

//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));
ibuildingcontrol:=true;


//vars
iloaded           :=false;
itimer500         :=ms64;



//controls
with rootwin do
begin
scroll:=false;
static:=true;
xhead.tag:=-1;
xhead.caption2:='  -  Interactive Archive by '+app__info('author.name');

//xhead.add('Nav',tepNav20,0,scpage+'nav','Previous midi');
with xhead do
begin

xaddoptions;
xaddhelp;


end;

iboxed      :=tarchive.create( client ,'' );

end;



//events


//defaults
ibuildingcontrol:=false;
xloadsettings;

//finish
createfinish;
end;

destructor tapp.destroy;
begin
try

//save settings
xsavesettings;

//controls

//self
inherited destroy;
except;end;
end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
begin
try

//can close app safely -> tell system it's safe to shutdown now - 09may2026
if app__closeinited then
   begin

   //prompt App Clean Up (not when an MSIX app) -> removes app's storage folder and its contents
   if (not system_msix) and (not gui.popqueryex2('Clean Up','Keep app settings for next time?','No - Discard them now','Yes - Keep them',500,200,60,0)) then
      begin

      app__cleanuponclose:=true;

      end;

   //OK to close the app
   app__closepaused:=false;

   end;


//timer500
if (ms64>=itimer500) then
   begin

   //savesettings
   xautosavesettings;

   //reset
   itimer500:=ms64+500;

   end;

except;end;
end;

procedure tapp.xloadsettings;
begin
try

//check
if zznil(prgsettings,5001) then exit;

//filter
iboxed.settings       :=prgsettings.text;

//sync
prgsettings.text      :=iboxed.settings;

except;end;

//loaded
iloaded:=true;

end;

procedure tapp.xsavesettings;
begin
try

//check
if not iloaded         then exit;

//set
prgsettings.text      :=iboxed.settings;
siSaveprgsettings;

except;end;
end;

procedure tapp.xautosavesettings;
var
   str1:string;
begin
try

//check
if not iloaded then exit;

//get
str1:=iboxed.settingsREF( false );
if low__setstr(isettingsref,str1) then xsavesettings;

except;end;
end;

end.
