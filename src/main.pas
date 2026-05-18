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
//## Version.................. 2.00.077   - public version for Archive + Content
//## Code Version............. 2.00.2666  - internal version
//## Items.................... 4
//## Last Updated ............ 19may2026 ,15may2026, 09may2026, 08may2026, 06may2026, 05may2026, 04may2026, 03may2026
//## Lines of Code............ 5,700+
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
//## | tmanagecursor          | tobject           | 1.00.520  | 14may2026   | System cursor customisation support with undo/redo/reset options - 11may2026
//## | tmanagebackground      | tobject           | 1.00.622  | 19may2026   | System Desktop Background (picture mode) customisation support with undo/redo and multi-monitor support - 14may2026
//## | tarchive               | tbasicscroll      | 1.00.1502 | 19may2026   | Interactive archive - 14may2026, 11may2026, 09may2026, 06may2026, 05may2026, 04may2026, 03may2026
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

   //backgrounds ---------------------------------------------------------------

   //background mode
   wm_one               =0;
   wm_all               =1;
   wm_max               =1;


   //cursors -------------------------------------------------------------------

   //cursor index
   ci_arrow             =0;
   ci_hand              =1;
   ci_max               =1;

   //system cursor index
   ocr_normal           =32512;//normal
   ocr_ibeam            =32513;//select text
   ocr_wait             =32514;//busy
   ocr_cross            =32515;//Precision select
   ocr_up               =32516;//Alternate select
   ocr_sizeNWSE         =32642;//Diagonal resize 1
   ocr_sizeNESW         =32643;//Diagonal resize 2
   ocr_sizeWE           =32644;//Horizontal resize
   ocr_sizeNS           =32645;//Vertical resize
   ocr_sizeall          =32646;//Move
   ocr_no               =32648;//Unavailable
   ocr_hand             =32649;//Link select
   ocr_appstarting      =32650;//Working in background


   //archive -------------------------------------------------------------------

   //app specific images
   tepREADME20          =tepCustomBASE20 + 0;
   tepLicense20         =tepCustomBASE20 + 1;
   tepScrollDown20      =tepCustomBASE20 + 2;
   tepMask20            =tepCustomBASE20 + 3;
   tepMouseDialog20     =tepCustomBASE20 + 4;
   tepThemesDialog20    =tepCustomBASE20 + 5;
   tepArrow20           =tepCustomBASE20 + 6;
   tepHand20            =tepCustomBASE20 + 7;
   tepBackground20      =tepCustomBASE20 + 8;

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

   //com codes
   CLSID_DesktopWallpaper : TCLSID = '{C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD}';
   SID_DesktopWallpaper            = '{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}';

type

//IDesktopWallpaper
   IDesktopWallpaper = interface( IUnknown )
    [SID_DesktopWallpaper]
    procedure SetWallpaper( monitorID:PWideChar; wallpaper:PWideChar ); safecall;
    function  GetWallpaper( monitorID:PWideChar ): PWideChar; safecall;
    function  GetMonitorDevicePathAt( monitorIndex:iauto ): PWideChar; safecall;
    function  GetMonitorDevicePathCount:iauto; safecall;
    function  GetMonitorRECT( monitorID:PWideChar ):twinrect; safecall;
    procedure SetBackgroundColor( color:COLORREF32 ); safecall;
    function  GetBackgroundColor:COLORREF32; safecall;
    procedure SetPosition( position:longint32 ); safecall;
    function  GetPosition:longint32; safecall;
    procedure SetSlideshow( items:pauto ); safecall;
    function  GetSlideshow:pauto; safecall;
    procedure SetSlideshowOptions( options:longint32; slideshowTick:iauto ); safecall;
    procedure GetSlideshowOptions( out options:longint32; out slideshowTick:iauto ); safecall;
    procedure AdvanceSlideShow( monitorID:PWideChar; direction:longint32 ); safecall;
    function  GetStatus:longint32; safecall;
    procedure Enable( enable:LongBool ); safecall;
   end;

//11111111111111111111111111111111111111
{tmanagewallpaper}
   tmanagewallpaperitem=record

    dslot             :array[0..99] of string;//image data
    wslot             :array[0..99] of widestring;//image filename

    dlast             :string;
    wlast             :widestring;

    end;

   tmanagebackground=class(tobject)
   private

    iundoinfo         :tstr8;//control info
    ilist             :array[0..19] of tmanagewallpaperitem;
    icount            :longint32;
    icom              :IDesktopWallpaper;

    function xisfilename     (const x:string):boolean;
    procedure xinititem      (const xindex:longint32);
    procedure xfreeitem      (const xindex:longint32);
    function xfromstr        (const xindex:longint;const ddata:string;wdata:widestring):boolean;
    function getfilename     (xindex:longint):widestring;
    procedure setfilename    (xindex:longint;x:widestring);
    property filename        [xindex:longint]:widestring read getfilename write setfilename;
    function xtempfile       (const xindex:longint):string;//19may2026

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //canmode
    function canmode         (const xmode:longint32):boolean;

    //undo
    function canundo         :boolean;
    function undo            :boolean;

    //redo
    function canredo         :boolean;
    function redo            :boolean;

    //fromdata
    function canfromdata     (const xmode:longint32):boolean;
    function fromdata        (const xmode:longint32;const xdata:pobject):boolean;

    //fromfile
    function canfromfile     (const xmode:longint32):boolean;
    function fromfile        (const xmode:longint32;const xfilename:string):boolean;

    //fromstr
    function canfromstr      (const xmode:longint32):boolean;
    function fromstr         (const xmode:longint32;const xdata:string):boolean;

    //fromrec
    function canfromrec      (const xmode:longint32):boolean;
    function fromrec         (const xmode:longint32;const xdata:array of byte):boolean;

    //ms pages
    procedure pageBackground;

   end;


{tmanagecursor}
   tmanagecursoritem=record

    undoslot          :array[0..199] of string;
    lastdata          :string;

    ocr_index         :longint32;
    res_name          :pansichar;//use makeintresource(ocr_index) to set value
    reg_name          :string;

    end;

   tmanagecursor=class(tobject)
   private

    iundoinfo:tstr8;
    ilist:array[0..ci_max] of tmanagecursoritem;

    function xisfilename     (const x:string):boolean;
    function xfindOCRIndex   (const xindex:longint32):longint32;
    function xfindREGname    (const xindex:longint32):string;
    procedure xinititem      (const xindex:longint32);
    procedure xfreeitem      (const xindex:longint32);
    function xfromstr        (const xindex:longint;const xdata:string):boolean;
    function xfinddefault    (const xindex:longint32):string;//11may2026

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //can
    function can             (const xindex:longint32):boolean;

    //reset
    function canreset        :boolean;
    function reset           :boolean;//restore cursor to system default

    //undo
    function canundo         :boolean;
    function undo            :boolean;

    //redo
    function canredo         :boolean;
    function redo            :boolean;

    //fromdata
    function canfromdata     (const xindex:longint32):boolean;
    function fromdata        (const xindex:longint32;const xdata:pobject):boolean;

    //fromfile
    function canfromfile     (const xindex:longint32):boolean;
    function fromfile        (const xindex:longint32;const xfilename:string):boolean;

    //fromstr
    function canfromstr      (const xindex:longint32):boolean;
    function fromstr         (const xindex:longint32;const xdata:string):boolean;

    //fromrec
    function canfromrec      (const xindex:longint32):boolean;
    function fromrec         (const xindex:longint32;const xdata:array of byte):boolean;

    //windows support
    procedure mousePropertiesDialog;
    procedure mouseSettingsDialog;

   end;


{tarchive}
   tarchive=class(tbasicscroll)
   private

    icursor                  :tmanagecursor;//11may2026
    ibackground              :tmanagebackground;//14may2026

    istartfile               :string;
    ifirstfileload           :boolean;
    imaskCustom              :string;
    imaskCustom2             :string;
    imaskmode                :longint32;
    ilastmaskmode            :longint32;
    ishowmore                :boolean;

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

    icursorbar               :tbasictoolbar;
    ibackgroundbar           :tbasictoolbar;

    icursorvsep1             :tbasicbreak;
    icursorvsep2             :tbasicbreak;

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
    ilastfilesysOK           :boolean;
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

mtep_Background20
:array[0..373] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,20,0,0,0,20,8,6,0,0,0,141,137,29,13,0,0,1,61,73,68,65,84,120,1,172,148,177,141,133,48,12,134,157,167,27,0,177,4,204,64,77,195,14,136,154,150,130,150,2,209,35,81,81,35,118,160,161,70,108,0,67,32,196,6,92,28,157,163,192,193,11,121,122,145,34,59,177,253,233,183,65,97,142,227,192,55,215,15,194,230,121,134,36,73,246,56,142,63,98,215,117,13,101,89,50,215,117,129,161,194,32,8,118,126,1,77,211,192,182,109,70,80,203,178,32,138,34,20,4,93,215,49,161,16,149,33,140,7,152,17,237,47,153,215,138,238,56,16,94,4,48,85,70,117,104,213,90,161,80,13,190,243,125,223,223,251,190,23,41,216,34,206,237,156,47,21,158,3,87,231,162,40,96,28,71,168,170,10,97,87,41,96,164,112,89,22,240,60,239,18,68,151,70,10,211,52,133,97,24,68,45,111,159,24,7,107,164,112,154,38,57,51,154,229,129,198,15,90,32,254,240,52,175,187,15,161,66,223,182,76,176,60,207,1,55,130,241,78,5,156,253,91,32,193,80,85,150,101,12,55,250,58,232,37,80,133,113,128,156,27,250,58,232,63,224,29,140,
90,211,65,15,64,29,236,9,84,2,195,48,164,249,160,149,109,18,228,108,85,165,88,75,235,240,124,173,235,10,109,219,82,236,145,69,152,109,219,242,249,18,192,175,63,176,143,164,60,76,250,5,0,0,255,255,3,0,88,39,176,172,120,219,31,90,0,0,0,0,73,69,78,68,174,66,96,130);


mtep_Arrow20
:array[0..534] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,16,0,0,0,20,8,6,0,0,0,132,98,189,119,0,0,1,222,73,68,65,84,120,1,156,211,191,75,2,81,28,0,240,103,37,228,143,173,223,214,5,13,217,133,69,81,70,131,209,208,16,130,66,224,210,236,224,104,168,156,169,160,32,10,122,127,128,232,232,80,171,67,16,148,74,96,186,233,224,210,154,171,147,215,160,67,6,114,125,191,135,79,78,243,103,7,143,247,222,221,247,251,121,223,123,247,142,16,184,20,10,69,4,218,18,142,103,189,230,48,193,233,116,158,251,253,254,23,64,150,255,5,48,12,67,0,56,11,4,2,175,128,172,204,130,72,21,96,130,86,171,37,62,159,239,52,24,12,34,178,58,45,210,3,40,194,113,220,73,40,20,202,2,178,54,13,210,7,200,144,227,46,178,62,9,249,3,96,130,70,163,33,94,175,247,40,28,14,231,160,146,141,113,200,80,0,19,212,106,53,241,120,60,135,145,72,4,17,221,40,100,36,64,17,151,203,117,208,69,54,135,33,99,1,138,184,221,110,67,52,26,205,67,37,91,131,200,68,0,19,84,42,21,129,74,246,99,177,24,34,12,180,158,51,21,64,17,56,177,108,60,30,207,195,124,155,
10,99,129,86,171,69,74,165,18,41,22,139,82,171,84,42,196,96,48,236,177,44,251,6,85,236,32,178,64,37,218,183,219,109,146,203,229,136,213,106,149,190,68,38,147,121,79,36,18,55,240,92,164,49,221,254,27,251,62,0,147,147,201,228,39,207,243,153,106,181,122,175,211,233,136,205,102,187,0,128,17,69,241,99,0,144,166,189,87,160,201,112,128,174,27,141,6,95,40,20,4,140,48,26,141,243,102,179,249,78,190,113,114,72,2,4,65,32,169,84,170,134,201,176,82,13,2,190,210,233,244,99,179,217,148,94,195,110,183,223,194,189,209,63,24,232,73,220,20,249,42,48,222,205,102,179,63,157,78,71,172,215,235,162,94,175,231,228,43,247,141,33,120,81,158,140,15,113,238,112,56,158,160,10,177,92,46,119,44,22,203,243,96,76,31,50,108,162,84,42,175,76,38,211,3,36,94,66,235,237,151,60,246,23,0,0,255,255,3,0,122,245,149,33,205,108,88,224,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_Hand20
:array[0..634] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,2,66,73,68,65,84,120,1,98,96,192,2,24,25,25,185,122,122,122,142,172,89,179,230,149,180,180,180,21,22,37,24,66,76,24,34,16,1,13,127,127,127,235,128,128,0,81,111,111,111,127,28,106,80,132,113,25,196,200,204,204,204,192,196,196,196,192,194,194,194,136,162,3,7,7,151,65,40,202,129,94,101,2,98,20,49,116,14,65,131,190,124,249,162,189,100,201,146,7,83,166,76,185,0,52,76,55,38,38,166,81,94,94,222,158,100,131,126,252,248,225,17,18,18,34,27,20,20,164,159,157,157,189,127,246,236,217,117,147,38,77,218,160,171,171,27,92,87,87,183,64,64,64,192,0,100,40,11,186,201,88,248,192,160,98,2,135,151,172,172,172,48,27,27,27,131,136,136,136,64,83,83,211,66,95,95,95,110,113,113,113,73,160,5,238,4,189,134,197,96,176,16,47,47,47,55,40,220,128,134,114,131,4,8,26,244,239,223,63,184,89,255,255,255,135,179,209,25,120,13,2,105,156,55,111,30,216,91,66,66,66,12,57,57,57,96,253,198,198,198,12,214,214,214,40,102,129,13,50,
48,48,112,158,53,107,214,158,178,178,178,217,64,231,42,35,171,224,230,6,187,28,108,24,39,39,39,88,138,149,149,149,1,20,86,200,0,28,216,233,233,233,21,201,201,201,206,127,254,252,97,112,115,115,11,43,46,46,158,141,172,136,24,54,216,160,109,219,182,109,241,244,244,116,6,198,10,163,163,163,35,223,138,21,43,138,64,182,146,2,192,6,109,217,178,101,162,168,168,168,116,75,75,75,41,48,58,25,212,212,212,240,39,99,44,54,192,53,0,195,134,185,162,162,98,85,109,109,109,16,59,59,59,22,165,216,133,86,173,90,117,52,50,50,210,6,110,16,72,25,208,48,209,149,43,87,158,13,14,14,150,197,174,13,83,180,189,189,125,109,77,77,77,8,138,65,32,101,64,47,218,3,189,186,195,196,196,132,3,83,27,170,200,171,87,175,24,128,69,77,194,201,147,39,23,98,24,4,74,173,54,54,54,177,83,167,78,157,167,173,173,141,51,11,253,254,253,155,97,230,204,153,199,11,10,10,28,129,233,237,39,134,65,32,59,65,134,89,90,90,70,181,182,182,206,4,210,60,232,49,248,246,237,91,6,96,204,30,207,207,207,15,2,26,242,2,213,157,104,60,144,97,64,172,
156,153,153,57,9,24,160,183,247,237,219,247,123,199,142,29,159,129,185,255,144,131,131,67,10,80,14,37,69,2,0,0,0,255,255,3,0,153,29,156,33,111,10,148,101,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_MouseDialog20
:array[0..454] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,17,0,0,0,20,8,6,0,0,0,107,160,214,73,0,0,1,142,73,68,65,84,120,1,220,84,177,138,194,64,16,125,57,44,213,88,218,152,218,70,108,132,84,226,15,4,59,59,27,203,124,67,162,149,149,96,101,103,35,72,16,193,50,249,128,124,64,154,96,107,33,72,138,116,10,41,3,185,204,220,237,170,167,241,174,177,185,64,178,155,153,217,55,111,102,119,159,130,252,41,149,74,52,160,211,233,100,147,201,4,173,86,139,255,159,125,60,207,195,108,54,195,233,116,82,200,159,166,41,62,68,160,97,24,217,110,183,67,24,134,24,12,6,252,90,150,197,110,241,63,26,141,80,173,86,225,186,46,154,205,102,38,214,50,133,70,163,145,77,167,83,208,162,205,102,195,25,190,3,56,48,8,2,105,243,125,31,139,197,34,35,54,253,126,159,195,152,73,183,219,197,229,114,249,9,32,18,61,140,4,64,37,11,54,12,82,169,84,112,60,30,31,130,139,12,162,31,229,114,153,67,100,79,138,22,252,197,254,126,144,195,225,192,205,254,141,205,215,1,41,136,58,159,207,74,190,91,5,222,171,249,253,229,92,115,189,158,253,71,
38,81,20,161,221,110,191,46,252,198,43,142,123,28,199,108,229,158,208,205,85,85,149,165,224,38,182,112,218,235,245,176,223,239,165,28,48,8,221,5,199,113,64,90,82,171,213,228,21,127,134,66,44,76,211,196,114,185,148,110,185,59,243,249,156,141,235,245,186,16,136,0,182,219,45,235,73,46,78,82,30,120,34,148,141,88,16,136,166,105,32,102,185,142,32,73,18,212,235,117,232,186,142,225,112,200,246,241,120,44,1,238,148,141,104,208,49,207,133,70,177,109,155,245,98,181,90,129,212,142,4,43,79,192,106,119,11,32,234,249,4,0,0,255,255,3,0,184,119,144,221,11,99,56,93,0,0,0,0,73,69,78,68,174,66,96,130);

mtep_ThemesDialog20
:array[0..613] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,2,45,73,68,65,84,120,1,156,147,187,170,34,65,16,134,75,29,143,136,137,96,36,56,42,136,32,152,154,40,27,12,24,251,6,102,62,131,161,24,76,232,43,25,140,226,11,104,160,153,58,30,188,107,224,5,21,241,178,245,215,58,205,202,185,120,118,11,106,186,103,166,234,235,250,171,187,137,254,195,58,157,142,222,104,52,244,86,171,245,171,217,108,234,64,184,255,149,211,110,183,145,24,187,221,110,49,30,13,140,245,122,93,119,1,180,88,44,48,188,180,241,120,172,187,221,238,152,203,229,50,230,243,57,249,253,126,243,116,58,85,46,151,139,165,189,204,126,4,216,182,173,32,12,50,143,199,35,77,167,83,10,133,66,38,135,84,126,4,234,247,251,58,39,139,20,174,200,28,14,135,180,217,108,196,19,137,132,44,229,193,179,92,46,203,203,103,143,193,96,32,61,225,127,198,253,126,55,103,179,25,237,118,59,129,132,195,97,164,84,216,173,111,65,163,209,72,65,32,103,189,94,211,118,187,21,8,67,21,132,39,246,151,187,230,52,150,165,24,14,
4,114,0,130,103,50,25,74,165,82,20,137,68,208,39,250,180,34,222,69,169,196,129,44,151,75,5,0,44,157,78,63,85,147,203,229,222,63,84,196,187,161,107,154,166,26,59,153,76,68,138,35,41,24,12,162,71,149,253,126,111,113,172,157,76,38,223,65,125,218,181,183,183,55,217,29,214,111,240,249,48,123,189,30,97,155,15,135,131,52,24,9,56,55,92,169,197,83,59,155,205,10,4,223,149,180,64,32,32,149,48,204,96,55,187,221,46,241,217,145,106,120,117,242,120,36,84,118,8,144,66,161,160,32,181,90,237,15,168,90,173,74,37,232,9,32,72,138,199,227,20,141,70,137,143,63,113,179,177,168,130,20,139,69,5,193,15,1,177,94,105,44,228,240,189,49,25,70,215,235,85,220,235,245,210,106,181,122,130,148,74,165,39,136,3,210,206,231,179,172,8,0,18,1,225,187,163,198,124,62,143,216,151,134,102,227,38,27,12,48,89,214,19,4,64,190,152,47,33,8,208,88,191,28,56,159,207,167,32,78,85,8,96,201,170,55,220,187,15,178,16,3,211,30,71,157,32,145,43,19,7,136,13,0,152,197,110,127,7,65,16,164,89,236,78,18,79,149,89,143,153,205,151,243,203,74,
156,104,128,108,118,203,249,240,215,136,239,244,19,8,226,126,3,0,0,255,255,3,0,63,227,64,36,182,15,129,198,0,0,0,0,73,69,78,68,174,66,96,130);


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

//default Win11 Arrow Cursor - 15may2026
file__arrow_small_cur
:array[0..184] of byte=(
120,1,228,146,49,14,194,48,12,69,191,43,36,70,26,6,86,218,76,12,189,3,220,140,34,144,88,144,184,1,28,5,142,195,41,106,126,34,80,108,232,194,140,165,151,244,251,185,145,82,21,168,32,104,154,154,171,224,81,1,11,0,43,210,144,13,17,76,184,2,119,186,209,234,58,168,234,168,250,135,102,240,151,148,88,151,134,240,179,186,220,98,222,22,157,228,71,110,237,56,125,140,33,148,3,83,142,102,34,103,115,96,206,101,60,191,111,116,206,70,167,108,117,202,86,51,59,205,236,52,196,107,240,190,174,196,165,239,192,255,230,183,90,171,14,75,213,11,57,241,249,64,250,45,153,190,152,113,167,235,223,125,85,221,145,61,57,146,51,185,146,27,73,245,4,0,0,255,255,3,0,187,195,122,229);

file__arrow_eoa_cur
:array[0..6107] of byte=(
120,1,236,157,45,108,36,215,154,134,123,110,188,210,128,1,6,1,6,1,3,12,26,12,48,24,173,2,12,26,140,86,11,2,12,12,130,86,5,6,14,48,88,16,48,210,140,180,32,32,192,32,43,25,4,52,8,216,72,3,12,22,12,88,224,43,13,152,43,5,24,4,24,24,36,82,128,175,20,96,96,96,96,80,251,125,150,171,85,174,62,245,119,234,212,249,169,126,142,116,166,171,171,171,206,249,234,121,223,183,202,253,59,179,217,223,102,95,204,142,142,102,114,59,155,205,127,157,205,254,85,110,127,249,101,38,107,159,204,254,249,143,39,179,255,144,117,127,252,49,155,253,139,220,255,101,254,197,236,223,254,251,111,179,185,108,35,187,204,100,181,172,125,46,255,74,147,237,104,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,38,74,64,127,134,141,150,38,129,175,164,236,59,233,103,210,23,210,105,105,17,56,150,114,243,82,71,199,113,245,
219,113,56,188,142,117,91,210,14,29,29,194,173,25,42,147,245,154,25,23,173,154,189,178,126,197,178,230,113,223,197,100,140,113,79,32,147,127,149,237,255,72,223,146,110,219,182,101,199,107,233,247,58,237,238,238,230,7,7,7,133,102,166,219,83,217,118,207,118,50,246,91,17,200,100,169,224,251,65,150,109,53,124,95,26,39,95,46,151,185,182,243,243,115,116,20,48,35,182,76,198,46,244,211,91,27,13,215,178,119,119,119,119,175,95,241,79,7,29,223,203,220,180,254,4,50,217,165,172,159,141,134,239,203,99,156,156,156,20,178,173,221,158,157,157,229,139,197,162,58,159,222,95,72,167,245,39,144,201,46,38,158,31,101,253,179,14,195,61,202,222,206,206,78,126,123,123,187,166,91,121,197,229,229,101,190,181,181,85,158,243,172,195,60,108,98,38,144,201,234,50,203,242,242,39,121,172,77,195,255,44,239,127,124,124,92,150,202,184,156,101,89,121,14,93,94,72,167,217,17,200,100,183,21,207,74,46,116,125,147,134,79,229,241,171,98,127,203,236,233,248,52,123,2,153,236,186,210,239,231,159,127,206,159,61,123,182,186,255,
240,88,157,134,71,229,125,45,179,119,32,99,208,236,9,100,178,235,74,175,223,127,255,61,255,244,233,83,23,13,31,101,111,123,123,59,191,185,185,49,158,47,139,149,134,235,222,185,125,217,236,249,64,32,147,219,71,250,41,111,213,240,203,47,191,92,173,127,216,166,156,195,71,217,123,247,238,93,33,83,237,237,235,215,175,171,227,145,189,7,17,6,220,100,15,218,220,179,213,252,21,237,226,226,34,215,107,90,249,113,89,254,77,186,190,199,176,186,238,105,246,174,175,175,139,221,140,183,87,87,87,249,211,167,79,203,99,145,61,129,232,160,101,50,198,138,107,89,63,21,162,70,195,213,235,100,186,111,151,236,29,29,29,173,230,120,152,143,236,9,8,7,45,147,49,86,108,171,250,53,104,120,191,143,254,173,99,145,61,205,48,205,13,129,76,134,105,212,175,73,67,205,85,91,51,100,79,231,164,185,33,144,201,48,173,250,153,52,212,235,153,94,215,154,154,225,186,119,41,243,217,190,70,238,230,136,167,53,74,38,135,211,73,191,66,195,249,124,126,191,189,101,246,222,202,124,207,29,116,151,239,59,75,57,201,182,76,42,239,172,
159,106,168,153,218,219,219,179,201,222,106,158,242,156,22,203,250,249,154,67,233,180,217,44,19,8,43,174,166,191,95,76,231,199,234,251,67,166,109,12,215,189,213,60,229,57,123,46,163,157,0,43,181,76,150,87,92,187,234,103,210,171,188,206,112,221,91,205,81,158,175,231,50,218,9,176,74,203,228,254,138,173,43,253,244,121,163,190,7,111,211,127,250,233,39,211,235,6,104,87,17,238,225,238,40,250,149,179,216,103,89,207,203,135,135,135,43,63,61,120,11,237,204,218,233,218,76,250,138,151,171,252,245,209,172,216,22,237,84,142,222,45,147,61,130,235,135,118,189,117,43,118,8,174,31,218,21,82,88,221,6,213,15,237,172,52,43,239,20,76,63,180,43,203,96,189,28,68,63,180,179,214,171,186,163,119,253,208,174,42,193,160,251,94,245,67,187,65,90,153,118,246,170,31,207,205,77,18,12,90,231,77,63,195,235,217,188,174,50,72,186,251,157,189,232,135,118,195,133,170,25,97,116,253,208,174,134,188,155,213,163,234,135,118,110,68,106,24,101,52,253,208,174,129,186,187,135,70,209,15,237,220,9,212,50,146,115,253,208,174,
133,184,219,135,157,234,135,118,110,197,233,48,154,51,253,208,174,3,109,247,155,56,209,207,160,157,190,39,252,198,125,185,140,88,33,144,201,253,65,239,191,215,104,167,223,47,163,141,79,32,147,41,172,245,67,187,241,5,106,153,193,90,63,180,107,33,235,231,97,43,253,208,206,143,56,29,102,233,173,31,218,117,160,234,111,147,94,250,161,157,63,97,58,206,212,89,63,180,235,72,212,239,102,157,244,67,59,191,162,244,152,173,85,63,180,235,65,211,255,166,141,250,161,157,127,65,122,206,88,171,31,218,245,36,25,102,115,163,126,104,23,70,12,139,89,215,244,67,59,11,138,225,118,121,164,159,225,243,153,250,218,40,175,69,135,211,167,109,230,71,250,201,198,171,215,178,31,150,209,174,141,96,216,199,179,7,157,170,186,145,187,176,186,116,157,189,78,63,114,215,149,96,216,237,76,250,161,93,88,77,250,204,94,213,15,237,250,208,11,191,109,89,63,180,11,175,71,223,10,10,253,208,174,47,185,56,182,87,253,208,46,14,45,108,170,104,251,255,57,108,198,100,31,8,64,0,2,16,128,0,4,32,224,156,128,254,7,237,191,72,63,120,
50,155,61,185,255,57,234,217,236,239,255,144,59,52,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,154,8,44,228,193,115,233,122,75,131,64,108,4,206,164,160,252,161,235,242,66,58,13,2,49,16,88,72,17,133,55,203,183,248,52,6,117,168,65,125,88,246,101,117,89,31,255,26,76,16,8,224,131,133,204,89,245,99,221,253,83,217,118,79,58,109,115,9,220,200,161,239,123,60,124,245,92,157,31,235,214,227,83,143,2,69,54,149,122,194,151,71,245,92,88,231,193,46,235,241,105,
100,230,241,80,78,225,11,31,30,93,59,119,110,109,109,229,31,63,126,204,179,44,203,117,185,163,127,241,169,7,99,68,50,69,217,19,234,209,87,35,213,101,60,119,170,47,139,118,121,121,153,31,30,30,150,235,105,91,198,167,35,137,21,209,176,85,15,220,73,109,135,35,212,183,118,238,148,57,242,243,243,243,194,158,171,91,93,119,112,112,80,173,171,238,190,214,187,148,190,59,66,205,12,25,158,128,73,119,215,30,157,203,97,174,205,163,30,108,106,61,125,250,151,204,241,52,60,78,42,112,76,96,205,55,50,190,174,115,233,209,229,195,152,143,230,50,157,59,77,126,237,232,211,247,50,7,109,122,4,30,121,70,14,175,124,223,133,71,245,186,171,227,148,199,189,191,126,155,188,216,180,238,215,95,127,173,123,14,117,45,227,111,75,167,77,143,192,35,223,200,225,85,239,171,183,178,1,135,189,52,140,153,127,254,252,185,201,138,198,199,150,203,101,181,182,226,254,251,1,245,177,107,220,4,10,141,219,110,143,44,14,195,120,238,92,44,22,70,255,53,173,188,187,187,203,119,119,119,77,53,114,238,180,16,38,161,93,76,154,215,173,
235,235,209,159,132,195,218,88,103,103,103,77,86,52,62,198,185,51,33,71,185,45,117,205,63,45,175,147,119,245,232,142,148,121,91,245,167,227,115,167,142,175,243,208,166,75,96,205,159,39,39,39,249,206,206,206,218,122,65,80,172,235,226,209,227,210,246,197,126,185,205,185,243,195,135,15,171,253,43,99,234,28,180,105,19,88,211,94,61,116,113,113,209,230,209,183,13,88,140,231,206,189,189,61,227,181,187,109,165,238,39,115,85,59,231,206,6,1,38,244,80,85,247,213,57,78,61,250,213,87,95,173,61,94,242,74,221,249,203,120,238,60,61,61,109,179,226,218,227,186,79,105,190,242,114,221,220,19,146,134,67,49,105,95,190,6,95,93,93,229,243,249,188,236,139,234,114,213,39,156,59,177,149,75,2,85,191,173,206,159,197,201,172,167,71,255,203,228,121,206,157,46,37,219,168,177,90,253,169,62,237,232,209,109,33,119,93,245,167,158,127,109,26,127,119,110,148,15,235,14,182,147,63,59,122,244,162,234,77,189,175,175,93,246,109,13,127,119,158,212,29,8,235,39,73,160,179,63,11,143,190,120,241,98,109,31,245,161,169,235,123,
62,250,222,79,223,246,242,229,75,211,120,250,94,43,159,163,155,164,13,107,15,106,205,7,229,231,71,38,95,221,220,220,228,251,251,251,107,251,153,252,105,115,238,212,249,77,99,201,186,101,237,81,240,192,84,9,172,121,161,205,159,234,217,46,30,125,254,252,185,213,185,83,223,99,18,216,213,206,185,115,170,14,108,62,174,170,15,214,158,191,155,206,161,93,60,122,124,124,92,183,107,237,122,206,157,205,98,109,224,163,214,254,108,242,168,190,63,122,123,123,91,235,195,186,7,56,119,110,160,3,155,15,121,144,63,11,143,190,122,245,234,209,56,156,59,155,161,243,104,103,2,143,124,37,123,117,190,190,151,207,129,250,28,189,248,238,165,227,115,167,214,247,127,210,151,158,250,247,50,207,150,116,90,28,4,156,248,83,189,90,120,212,230,220,249,233,211,167,181,58,4,143,239,117,87,50,167,126,151,143,22,15,129,53,15,116,121,254,94,62,119,150,151,213,163,54,127,119,246,248,62,241,90,189,130,210,197,58,188,25,143,39,203,149,172,105,59,196,159,101,175,118,93,214,239,103,58,242,152,237,56,120,179,236,136,184,
150,215,52,245,237,207,192,231,78,253,222,60,215,244,184,60,89,174,38,168,63,175,175,175,239,127,123,73,127,231,102,140,94,243,157,186,226,152,125,252,230,84,153,53,203,253,9,20,90,173,110,125,159,63,187,254,29,208,119,59,253,94,72,195,119,169,240,102,127,175,132,216,99,229,75,153,252,126,121,10,254,196,155,33,172,52,202,156,147,243,39,222,28,197,39,161,6,157,148,63,241,102,40,27,141,54,239,100,252,137,55,71,243,72,200,129,39,225,79,188,25,210,66,163,206,157,188,63,241,230,168,254,8,61,120,210,254,212,247,237,121,13,41,180,133,70,157,63,89,127,170,55,159,61,123,182,86,191,208,210,117,188,190,57,170,109,188,13,190,166,111,10,175,127,226,77,111,254,8,61,81,114,254,196,155,161,45,227,117,254,164,252,137,55,189,122,35,134,201,146,241,39,222,140,193,46,222,107,72,194,159,120,211,187,47,98,153,48,122,127,226,205,88,172,18,164,142,168,253,137,55,131,120,34,166,73,163,245,39,222,140,201,38,193,106,137,210,159,120,51,152,31,98,155,56,58,127,226,205,216,44,18,180,158,168,252,137,55,131,
122,33,198,201,163,241,39,222,140,209,30,193,107,138,194,159,120,51,184,15,98,45,32,184,63,241,102,172,214,136,162,174,160,254,196,155,81,120,32,230,34,130,249,19,111,198,108,139,104,106,11,226,79,188,25,141,254,177,23,226,221,159,120,51,118,75,68,85,159,87,127,226,205,168,180,79,161,24,111,254,196,155,41,216,33,186,26,189,248,179,197,155,250,127,199,28,68,71,134,130,98,32,48,186,63,59,120,243,48,6,16,212,16,37,129,81,253,249,219,111,191,53,125,7,88,207,155,120,51,74,91,68,83,212,104,254,188,184,184,200,245,255,242,144,35,53,117,188,25,141,5,162,46,100,205,59,46,190,255,142,55,163,214,60,165,226,156,251,19,111,166,36,127,244,181,58,245,39,222,140,94,239,212,10,116,230,79,188,153,154,244,73,212,235,196,159,120,51,9,173,83,44,114,176,63,241,102,138,178,39,83,243,32,127,226,205,100,116,78,181,80,107,127,226,205,84,37,79,170,110,43,127,226,205,164,52,78,185,216,222,254,196,155,41,203,157,92,237,189,252,137,55,147,211,55,245,130,59,251,19,111,166,46,117,146,245,119,242,39,222,76,82,
219,41,20,221,234,79,188,57,5,153,147,61,134,70,127,226,205,100,117,157,74,225,181,254,196,155,83,145,56,233,227,48,250,19,111,38,173,233,148,138,95,243,231,201,201,9,159,123,159,146,194,105,31,203,154,63,27,254,63,75,190,147,145,182,214,41,86,191,230,79,57,8,211,58,188,153,162,186,233,215,108,242,98,117,29,222,76,95,231,84,143,160,234,197,234,125,188,153,170,178,211,168,187,234,199,242,125,188,57,13,141,83,62,138,178,31,203,203,120,51,101,85,167,83,123,217,147,197,50,222,156,142,190,169,31,73,225,201,226,22,111,166,174,232,180,234,47,124,89,220,190,158,214,225,113,52,137,19,40,124,169,183,71,137,31,11,229,79,143,64,225,79,188,57,61,109,167,112,68,156,55,167,160,226,116,143,129,243,230,116,181,229,200,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,176,81,4,230,114,180,127,72,255,251,147,217,236,201,236,185,44,205,102,239,231,95,220,223,242,15,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,
16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,76,154,192,107,57,186,131,73,31,33,7,7,129,56,9,60,147,178,174,165,231,210,207,
165,127,35,157,6,1,8,248,33,112,36,211,104,246,202,253,76,238,47,164,211,32,0,129,241,8,60,149,161,175,164,151,179,87,94,38,135,227,177,103,100,8,152,174,125,229,252,21,203,228,16,175,64,192,45,129,182,107,95,145,189,242,45,57,116,171,1,163,141,79,64,95,87,220,26,127,154,222,51,100,178,71,57,91,125,150,201,97,111,220,236,16,136,192,82,230,253,32,61,166,12,106,45,151,210,251,100,206,180,237,255,202,24,123,210,105,16,136,149,128,230,79,189,27,83,6,179,135,154,76,153,178,89,119,42,227,145,67,129,64,139,142,64,145,63,245,245,153,116,125,191,45,100,107,188,246,109,111,111,231,79,159,62,181,201,160,238,67,14,67,42,203,220,38,2,75,89,89,246,243,39,185,31,50,131,89,165,158,114,109,249,241,241,113,126,117,117,149,191,121,243,38,223,218,218,122,244,88,211,126,149,199,200,161,0,161,69,65,160,154,63,245,116,200,12,234,103,92,140,185,210,107,223,237,237,109,94,180,203,203,203,60,203,50,114,24,133,141,40,194,146,128,41,127,161,50,168,175,197,26,179,167,235,223,189,123,87,68,239,209,173,131,
28,254,44,227,239,90,242,99,55,8,12,33,80,151,191,16,25,108,188,246,93,95,95,63,202,93,245,206,192,28,222,9,68,101,241,124,8,76,246,133,64,79,2,77,249,211,12,126,150,190,211,115,76,155,205,173,174,125,213,12,234,253,129,57,228,117,82,27,245,216,199,150,64,91,254,52,131,23,210,199,206,224,160,107,159,163,28,126,180,133,200,126,16,176,36,208,37,127,99,103,112,33,181,235,28,198,254,221,119,223,153,226,213,121,221,249,249,121,126,112,112,96,28,187,50,167,214,65,131,128,79,2,75,153,172,139,55,117,155,177,174,131,103,117,53,232,123,125,250,126,195,208,166,99,180,188,111,168,53,208,32,224,155,192,82,38,212,108,117,237,174,51,184,104,154,251,232,232,104,104,244,238,247,215,113,154,230,145,199,180,14,26,4,124,19,232,155,63,245,177,102,208,213,235,245,103,50,150,49,27,92,251,124,91,129,249,2,16,176,201,159,230,69,191,23,59,31,88,239,66,246,55,102,79,215,123,188,246,253,251,192,227,96,119,8,216,18,176,205,159,139,12,234,231,192,140,249,211,207,150,253,249,231,159,131,255,246,236,240,188,
79,95,119,165,65,32,20,129,218,252,117,252,124,165,237,117,80,223,103,51,102,79,215,235,231,202,92,180,183,111,223,214,206,241,48,191,190,239,72,131,64,40,2,181,249,251,254,251,239,243,249,124,222,230,95,125,220,38,131,141,215,62,125,15,125,104,211,207,203,232,103,70,165,190,186,206,181,47,148,235,152,183,32,176,172,243,231,114,185,188,127,237,255,229,203,151,117,254,45,175,215,12,118,253,236,136,151,107,159,126,94,180,238,216,30,214,115,237,19,16,180,160,4,26,243,167,215,160,155,155,155,124,127,127,191,205,203,250,248,141,244,253,14,71,195,181,175,3,36,54,217,8,2,173,249,115,156,65,125,223,66,63,235,108,204,243,183,223,126,59,244,207,206,251,253,185,246,109,132,119,167,112,144,157,242,231,48,131,181,243,105,38,245,179,98,67,27,207,251,166,96,203,141,57,134,218,60,232,243,191,106,27,248,183,104,227,181,79,63,163,233,162,117,184,246,101,27,163,46,7,26,59,129,94,249,211,124,104,6,95,189,122,149,203,129,181,117,125,62,184,40,1,168,157,75,199,242,116,237,211,223,85,219,42,213,196,
34,4,66,18,168,205,132,233,250,87,92,159,238,238,238,242,195,195,195,182,252,233,227,250,92,239,80,186,151,107,223,15,63,252,208,86,83,38,181,208,32,16,11,1,171,252,105,14,123,102,80,127,83,166,54,27,159,63,127,46,162,109,125,171,191,13,179,179,179,83,59,135,204,207,181,47,22,215,81,71,65,192,58,127,61,51,88,155,139,197,98,97,157,185,242,142,250,219,104,114,80,77,61,43,14,154,91,8,68,66,96,80,254,92,100,240,236,236,172,28,35,171,101,174,125,145,184,137,50,250,18,24,156,191,34,131,250,222,157,76,222,171,115,237,235,43,23,219,79,140,128,147,252,21,23,173,14,223,115,125,148,79,79,215,62,253,108,156,254,127,74,52,8,196,70,192,105,254,52,135,93,51,248,245,215,95,23,177,29,116,219,225,121,223,81,108,208,169,7,2,15,4,156,231,175,107,6,79,79,79,7,229,78,119,238,240,188,143,107,31,86,143,153,192,40,249,107,203,224,222,222,222,224,236,233,0,63,254,248,227,163,191,103,5,116,245,62,215,190,152,221,71,109,163,229,175,41,131,46,174,125,250,254,227,238,238,110,53,111,229,251,92,251,240,119,
236,4,70,205,159,102,176,250,252,204,213,181,79,63,159,35,112,155,186,30,219,34,178,174,159,3,162,65,160,32,48,122,254,170,25,244,116,237,107,202,101,168,199,92,255,118,99,161,33,183,233,18,240,146,191,34,131,30,175,125,161,50,86,55,47,217,75,55,35,99,86,238,45,127,154,193,191,254,250,75,111,6,181,14,207,251,234,50,16,106,61,217,27,211,193,105,143,237,53,127,131,130,247,176,115,135,231,125,161,114,102,154,151,236,165,157,143,177,171,79,42,127,137,93,251,200,222,216,238,77,127,252,164,242,151,208,181,79,191,235,52,246,255,217,150,190,251,56,130,164,242,247,250,245,235,92,63,179,29,162,191,120,241,194,244,247,165,105,157,190,239,56,244,183,249,113,230,102,16,72,42,127,46,158,63,218,140,161,191,99,63,226,111,17,111,134,211,56,74,19,1,242,215,18,72,178,103,178,13,235,28,17,32,127,13,249,35,123,142,92,198,48,117,4,200,95,77,254,200,94,157,101,88,239,144,0,249,51,228,143,236,57,116,24,67,53,17,32,127,149,252,145,189,38,187,240,152,99,2,228,175,148,63,178,231,216,93,12,215,70,128,252,
61,228,79,127,215,91,63,31,46,192,218,58,239,239,181,185,138,199,187,18,32,127,146,191,30,255,175,5,217,235,234,44,182,235,66,96,227,243,71,246,186,216,132,109,70,34,176,209,249,35,123,35,185,138,97,187,18,216,216,252,145,189,174,22,97,187,17,9,108,100,254,200,222,136,142,98,232,62,4,54,46,127,100,175,143,61,216,118,100,2,27,149,63,178,55,178,155,24,190,47,129,141,201,31,217,235,107,13,182,247,64,96,35,242,71,246,60,56,137,41,108,8,76,62,127,100,207,198,22,236,227,137,192,164,243,71,246,60,185,136,105,108,9,76,54,127,100,207,214,18,236,231,145,192,36,243,71,246,60,58,136,169,134,16,152,92,254,200,222,16,59,176,175,103,2,147,202,31,217,243,236,30,166,27,74,96,50,249,35,123,67,173,192,254,1,8,76,34,127,100,47,128,115,152,210,5,129,228,243,215,35,123,215,2,140,223,165,118,225,26,198,112,69,32,233,252,245,200,222,141,0,219,119,5,141,113,32,224,136,64,178,249,35,123,142,28,192,48,33,9,36,153,63,178,23,210,50,204,237,144,64,114,249,35,123,14,213,103,168,208,4,146,202,31,217,11,109,
23,230,119,76,32,153,252,145,61,199,202,51,92,12,4,146,200,31,217,139,193,42,212,48,2,129,232,243,71,246,70,80,157,33,99,33,16,117,254,238,238,238,242,111,190,249,38,23,88,109,157,247,247,98,113,20,117,244,33,16,109,254,52,123,135,135,135,109,185,211,199,201,94,31,197,217,54,38,2,81,230,143,236,197,100,17,106,25,145,64,116,249,35,123,35,170,205,208,177,17,136,42,127,100,47,54,123,80,207,200,4,162,201,31,217,27,89,105,134,143,145,64,20,249,35,123,49,90,131,154,60,16,8,158,63,178,231,65,101,166,136,149,64,208,252,145,189,88,109,65,93,158,8,4,203,31,217,243,164,48,211,196,76,32,72,254,200,94,204,150,160,54,143,4,188,231,143,236,121,84,151,169,98,39,224,53,127,100,47,118,59,80,159,103,2,222,242,71,246,60,43,203,116,41,16,240,146,63,178,151,130,21,168,49,0,129,209,243,71,246,2,168,202,148,169,16,24,53,127,100,47,21,27,80,103,32,2,163,229,143,236,5,82,148,105,83,34,48,74,254,122,100,239,78,96,45,82,2,70,173,16,112,72,192,121,254,122,102,239,208,225,177,48,20,4,82,35,224,52,127,100,
47,53,249,169,55,48,1,103,249,35,123,129,149,100,250,20,9,56,201,31,217,75,81,122,106,142,128,192,224,252,145,189,8,84,164,132,84,9,12,202,31,217,75,85,118,234,142,132,128,117,254,200,94,36,10,82,70,202,4,172,242,71,246,82,150,156,218,35,34,96,149,191,55,111,222,228,114,12,109,93,223,91,231,253,189,136,196,166,148,232,8,244,206,223,209,209,81,91,238,244,113,178,23,157,212,20,20,33,129,94,249,35,123,17,42,72,73,41,19,232,156,63,178,151,178,204,212,30,41,129,78,249,35,123,145,170,71,89,169,19,104,205,31,217,75,93,98,234,143,152,64,99,254,200,94,196,202,81,218,20,8,212,230,111,62,159,231,114,128,109,157,215,57,167,224,2,142,33,20,129,218,252,145,189,80,146,48,239,6,17,176,205,31,215,189,13,50,9,135,58,26,1,155,252,145,189,209,228,96,224,13,35,208,55,127,100,111,195,12,194,225,142,74,160,79,254,200,222,168,82,48,248,6,18,232,154,63,178,183,129,230,224,144,71,39,208,37,127,100,111,116,25,152,96,67,9,180,229,143,236,109,168,49,56,108,47,4,154,242,71,246,188,72,192,36,27,76,160,46,127,
100,111,131,77,193,161,123,35,80,151,191,204,91,5,76,4,129,205,37,96,202,223,209,230,226,224,200,33,224,149,64,53,127,100,207,43,126,38,219,112,2,229,252,145,189,13,55,3,135,239,157,64,145,63,178,231,29,61,19,66,96,166,249,35,123,24,1,2,97,8,204,195,76,203,172,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,129,52,9,252,191,0,0,0,0,255,255,3,0,86,107,109,70);

//default Win11 Hand Cursor - 15may2026
file__hand_small_cur
:array[0..280] of byte=(
120,1,172,141,177,74,195,80,20,134,255,196,4,42,56,116,18,178,101,116,148,32,130,83,178,103,17,164,25,116,52,185,29,178,136,186,73,72,209,119,200,160,163,15,16,112,136,67,150,142,121,12,179,57,102,44,65,122,122,146,230,214,164,80,186,244,92,190,123,249,254,195,57,23,80,161,192,52,199,56,225,243,171,2,167,0,206,24,147,113,24,5,26,223,192,156,123,187,202,247,125,20,69,1,215,117,145,36,9,234,186,70,20,69,48,12,3,105,154,194,178,44,148,101,185,107,252,208,185,118,115,117,219,219,57,250,16,34,124,248,15,222,4,215,215,198,71,151,141,223,111,252,184,81,17,58,50,240,90,23,102,231,250,90,133,92,248,34,178,54,233,250,90,22,124,246,93,13,175,215,19,114,254,17,122,152,231,121,38,29,208,131,187,201,119,210,119,111,50,221,231,79,14,100,233,129,247,252,46,133,95,61,120,157,245,148,189,111,77,127,143,79,135,125,245,98,232,135,51,218,174,229,17,209,66,33,170,64,244,131,152,230,204,12,118,11,96,47,153,191,142,229,152,243,115,166,26,16,83,197,59,42,155,137,135,44,182,63,35,90,1,0,0,255,255,3,0,
155,112,153,182);

file__link_eoa_cur
:array[0..9231] of byte=(
120,1,236,157,79,72,37,219,157,199,125,121,189,16,226,162,23,46,204,32,193,133,100,92,184,240,129,12,242,16,158,48,50,116,130,129,94,244,66,136,36,66,92,244,162,31,8,35,161,23,134,46,48,76,47,58,96,136,67,92,72,48,76,47,58,224,194,16,23,50,184,48,67,47,58,208,11,23,46,92,24,48,131,11,7,28,198,144,30,198,69,135,212,252,190,247,121,111,238,45,79,253,187,158,123,173,91,245,249,193,79,111,85,157,58,117,206,231,247,251,213,159,115,78,157,234,235,251,90,223,167,125,203,203,125,125,127,215,215,215,55,246,190,175,239,31,236,255,175,127,221,215,247,247,246,255,191,126,255,73,223,247,109,221,31,255,216,215,55,169,245,99,159,246,253,211,191,126,173,111,204,126,219,46,125,182,186,239,147,190,17,251,107,98,233,16,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,232,56,129,81,59,194,156,233,83,211,224,70,245,10,248,162,233,19,211,25,211,65,
83,164,24,4,6,172,24,11,166,59,166,87,166,97,70,61,179,116,111,76,159,153,98,79,131,208,101,153,178,227,137,255,181,105,86,155,197,165,251,104,121,236,154,42,110,145,206,18,152,177,236,223,153,198,217,226,174,235,223,90,222,227,166,136,95,2,15,45,187,45,83,167,125,6,6,6,194,249,249,249,112,99,99,35,60,58,58,10,175,174,174,194,186,92,94,94,134,103,103,103,225,187,119,239,194,221,221,221,112,117,117,53,124,244,232,81,248,240,225,67,103,94,118,12,197,99,96,250,192,20,185,59,129,89,203,226,210,244,22,111,217,65,54,185,190,190,174,155,43,243,255,143,31,63,134,59,59,59,225,220,220,92,248,224,193,131,91,121,219,241,246,76,117,125,69,218,39,160,251,72,197,67,11,223,199,143,31,215,226,44,179,177,82,18,158,156,156,212,98,50,122,28,91,62,54,229,254,198,32,228,20,157,187,54,77,91,236,54,50,50,18,238,239,239,167,88,163,253,205,123,123,123,161,206,197,145,227,234,154,200,185,212,32,228,144,215,150,182,133,227,210,210,82,91,231,201,188,214,60,62,62,14,135,134,134,90,142,109,101,217,206,81,246,
170,39,93,107,182,157,174,77,186,47,233,166,232,124,234,184,191,153,174,186,97,50,212,127,41,106,59,157,211,238,67,14,15,15,163,247,53,58,143,34,241,4,30,217,166,150,123,149,237,237,237,251,48,93,227,152,139,139,139,209,243,232,227,248,226,87,122,203,132,213,254,131,105,131,215,139,23,47,26,28,239,235,199,249,249,121,216,223,223,223,40,147,149,239,212,148,123,25,131,208,36,67,246,251,194,180,193,73,126,95,20,89,89,89,105,148,235,166,140,243,77,101,175,250,79,61,31,235,25,171,193,104,118,118,54,212,179,117,81,68,109,57,145,103,10,181,149,35,95,157,135,14,12,68,195,118,227,227,227,225,135,15,31,138,98,186,70,57,158,60,121,210,40,163,149,87,231,249,126,12,88,123,166,106,112,209,51,215,197,197,69,131,89,145,126,232,62,170,217,207,236,247,108,197,237,23,52,243,208,249,73,207,205,69,21,181,129,55,151,215,126,111,152,86,85,22,173,226,13,30,122,62,63,56,56,40,170,233,26,229,154,156,156,108,148,217,202,95,213,103,65,157,119,10,245,140,215,48,80,202,15,181,223,53,249,221,185,253,174,154,
168,95,180,112,207,120,41,102,107,108,126,249,242,101,179,253,244,187,74,207,129,133,126,198,107,24,41,225,135,250,10,205,102,205,58,90,145,0,212,51,222,81,115,221,139,246,140,151,96,182,198,38,181,135,54,215,193,126,207,152,150,93,116,142,217,55,109,212,125,98,98,162,144,207,120,13,67,197,252,168,168,253,182,154,109,55,60,60,92,216,103,188,24,179,53,86,87,208,126,171,205,182,211,51,158,250,213,122,85,52,206,166,185,62,246,91,99,24,203,42,26,83,219,168,175,158,241,228,191,189,44,142,54,152,145,146,26,239,214,51,222,235,215,175,123,217,116,181,178,87,196,126,186,95,81,31,89,35,246,214,214,214,114,217,78,99,53,21,171,205,99,56,115,101,208,161,196,21,177,223,98,179,237,22,22,22,50,211,84,95,169,198,115,214,247,87,191,233,230,230,102,230,253,59,157,176,34,246,107,60,231,105,252,79,214,24,82,191,195,216,216,88,195,118,117,27,234,255,219,183,111,59,109,154,76,249,87,192,126,122,78,111,216,64,253,214,89,36,201,118,202,175,40,125,241,21,176,159,218,147,26,246,83,125,211,36,198,118,39,
150,143,180,150,215,204,204,76,90,54,93,217,94,1,251,141,212,153,235,127,218,181,43,193,118,106,43,61,172,231,133,253,140,68,119,68,99,10,26,239,80,170,141,51,78,244,142,144,218,98,44,125,179,42,230,100,59,9,246,251,138,67,183,255,110,218,1,27,54,217,218,218,106,49,161,198,37,41,46,35,227,129,148,190,217,118,42,51,246,19,133,238,139,198,113,54,250,103,213,238,242,244,233,211,80,215,14,61,7,106,124,146,109,143,170,190,72,94,143,187,122,137,177,95,157,68,247,255,63,183,67,70,109,20,183,188,103,105,117,223,26,21,236,23,37,210,221,101,141,145,140,179,153,214,235,58,41,59,171,189,198,37,169,246,211,53,84,99,180,191,255,253,239,255,217,222,7,252,211,111,126,243,155,223,255,206,33,63,251,217,207,254,244,243,159,255,252,127,126,245,171,95,41,205,31,28,73,126,247,163,31,253,232,63,149,199,243,231,207,255,178,190,190,222,114,206,175,47,84,224,254,51,106,135,69,91,161,248,186,54,173,219,242,216,126,235,253,162,180,119,34,83,237,23,229,25,247,156,223,116,236,154,189,235,246,104,254,63,58,
58,90,47,95,168,119,12,93,18,61,158,229,59,98,90,5,209,125,233,136,105,244,26,151,84,119,236,151,68,167,248,219,176,95,241,109,148,84,66,236,151,68,167,248,219,176,95,241,109,148,84,66,236,151,68,167,248,219,176,95,241,109,148,84,66,236,151,68,167,248,219,176,95,241,109,148,84,194,123,179,159,198,13,184,222,255,85,187,187,21,184,89,71,146,42,80,241,109,93,181,223,231,159,127,222,108,151,48,58,94,78,246,156,158,158,110,78,163,249,216,226,218,254,42,110,186,90,245,59,98,63,107,223,116,53,141,133,223,253,238,119,155,109,83,235,223,82,223,151,198,193,233,221,68,205,113,103,165,106,86,141,43,71,226,9,116,196,126,122,7,51,42,154,187,208,209,31,217,108,171,232,111,205,149,145,167,45,48,190,150,229,221,210,17,251,25,174,90,27,118,253,250,38,219,69,230,38,136,218,42,186,172,247,23,213,199,137,36,19,200,109,191,95,252,226,23,209,208,170,141,61,180,195,68,109,16,14,14,14,214,250,25,28,115,156,253,193,210,255,139,105,203,124,52,55,121,168,76,147,166,72,58,129,220,246,251,236,179,207,90,222,
75,83,140,105,12,142,29,42,171,170,79,114,236,166,104,234,51,209,239,25,211,41,83,206,151,6,33,135,228,182,159,229,93,27,3,188,188,188,28,106,236,169,222,51,212,186,38,213,216,226,198,248,170,166,245,74,163,247,217,153,95,208,32,120,146,182,236,103,199,110,182,87,243,239,250,61,135,226,106,209,244,149,233,182,233,75,83,205,73,199,179,128,65,240,40,62,237,167,123,14,174,91,30,141,147,33,171,118,236,183,97,249,214,207,145,58,79,234,247,186,233,136,41,210,93,2,237,216,111,164,187,69,228,104,9,4,176,95,2,156,30,216,132,253,122,192,72,9,69,196,126,9,112,122,96,19,246,235,1,35,37,20,17,251,37,192,233,129,77,216,175,7,140,148,80,68,236,151,0,167,7,54,97,191,30,48,82,66,17,177,95,2,156,30,216,132,253,122,192,72,9,69,60,176,109,161,212,53,230,65,29,181,175,94,189,170,109,175,167,179,255,195,166,72,49,8,232,29,193,134,125,52,55,83,84,166,166,166,26,219,45,173,250,239,144,226,16,80,95,106,195,62,178,213,233,233,105,205,132,26,179,226,248,166,13,227,193,138,99,187,122,73,222,54,219,48,225,
55,99,138,234,196,138,245,95,239,88,107,94,145,70,28,58,126,107,174,11,245,159,35,197,36,160,57,185,52,191,136,203,134,26,19,177,84,204,98,83,170,8,1,93,15,159,153,6,166,43,166,79,76,53,150,5,129,0,4,32,0,1,8,64,0,2,109,17,208,64,243,95,155,62,254,164,175,239,147,155,225,122,191,251,189,45,32,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,168,14,129,113,171,234,130,105,96,186,101,122,96,122,120,163,123,246,127,219,116,211,52,184,209,69,251,63,103,250,208,20,129,128,111,2,163,150,225,170,169,252,240,131,105,120,7,61,181,125,119,76,151,77,167,77,31,152,34,16,200,75,160,238,
147,71,182,227,93,252,49,109,223,115,203,63,48,29,54,69,32,144,70,96,210,18,232,252,246,209,52,205,183,124,110,215,241,246,77,31,155,34,16,136,18,208,253,225,91,83,159,62,215,110,94,239,172,28,138,19,4,2,186,174,238,154,230,242,165,254,254,254,112,106,106,42,156,159,159,15,87,87,87,195,23,47,94,132,175,94,189,10,159,63,127,30,46,46,46,214,116,102,102,38,148,142,143,143,231,202,187,169,44,91,246,123,200,20,169,30,1,61,151,172,152,102,122,222,145,63,62,126,252,56,220,218,218,10,143,142,142,194,143,31,63,134,121,228,234,234,42,220,223,223,15,215,214,214,194,185,185,185,112,96,96,32,171,207,94,89,25,117,110,71,170,67,64,237,67,153,158,123,228,147,175,95,191,14,63,124,248,144,199,29,83,211,94,95,95,135,111,222,188,9,31,61,122,148,197,79,117,111,250,172,58,230,169,116,77,117,46,74,60,103,62,120,240,160,118,125,62,62,62,78,245,51,31,9,206,207,207,107,247,5,58,71,91,217,146,116,195,182,211,30,85,94,247,85,155,99,226,115,249,210,210,82,120,113,113,225,195,237,114,231,113,122,122,154,229,
124,186,93,94,243,84,182,102,58,231,232,89,35,246,220,164,103,152,183,111,223,230,246,169,78,236,176,187,187,27,62,124,248,48,182,172,86,15,245,21,32,229,32,48,96,213,136,109,55,210,115,202,203,151,47,115,63,239,116,194,47,155,243,60,57,57,9,199,198,198,146,124,116,190,28,230,169,116,45,116,222,60,52,117,218,121,104,104,40,124,255,254,125,179,91,20,234,247,229,229,101,56,61,61,237,44,187,213,73,247,208,19,166,72,239,18,120,109,69,119,218,119,114,114,242,222,238,51,243,4,129,218,13,84,214,152,122,168,29,159,231,165,222,244,207,181,24,155,214,218,212,125,183,23,229,241,185,188,105,245,188,54,60,60,28,231,163,122,230,67,122,139,192,146,21,215,105,79,61,159,247,162,168,173,43,166,253,73,215,249,145,222,50,79,165,75,59,107,181,119,182,33,169,45,60,111,191,79,145,124,89,125,168,86,55,151,110,87,218,226,189,83,121,245,11,57,219,222,39,38,38,188,247,1,117,219,119,21,91,49,207,244,215,86,111,250,233,139,237,167,178,207,133,233,173,243,139,238,221,238,171,205,221,183,15,31,30,30,222,170,
223,77,157,215,139,109,158,74,151,78,109,156,199,55,118,106,177,159,218,55,213,150,88,38,137,105,115,210,57,84,28,144,98,17,80,251,202,129,105,139,95,106,89,253,232,58,223,148,77,212,191,228,170,175,173,91,48,69,138,69,96,219,138,227,180,151,198,29,149,85,70,71,71,93,117,214,56,86,164,56,4,2,43,138,203,78,181,113,150,101,245,77,213,75,99,162,29,117,231,26,95,28,223,92,116,216,167,102,179,94,109,227,204,19,79,26,35,29,83,127,222,95,186,127,31,45,109,27,103,30,31,141,185,198,243,28,127,191,254,89,234,54,206,60,254,249,244,233,83,215,57,84,239,5,32,247,67,64,109,156,231,166,183,236,82,166,54,206,172,62,170,247,67,92,44,108,93,191,41,210,93,2,106,219,211,185,225,150,77,202,216,198,153,197,71,245,94,136,139,135,173,99,220,157,65,232,162,168,141,83,115,23,220,178,71,89,219,56,179,248,167,210,196,140,179,103,236,114,23,157,211,14,21,251,110,70,153,219,56,179,248,104,204,216,80,222,255,232,158,127,138,245,173,243,166,214,233,93,242,170,203,194,194,130,139,141,226,25,233,60,1,245,215,
185,248,135,85,104,227,204,18,123,43,43,43,46,62,186,23,66,58,75,96,198,178,47,229,56,206,44,126,151,53,141,230,212,49,78,81,213,88,25,164,115,4,198,44,235,210,142,227,204,234,123,89,210,109,111,111,71,125,83,203,103,157,51,77,229,115,166,141,51,139,99,222,164,193,63,187,26,47,106,227,124,111,122,235,156,80,213,54,206,52,87,197,63,187,230,159,106,227,220,115,249,102,213,219,56,147,124,20,255,236,154,127,110,186,124,83,235,170,222,198,153,228,159,27,27,27,183,174,53,198,236,164,107,86,171,198,129,158,203,15,93,74,27,103,146,119,134,97,204,59,157,135,213,112,155,174,212,82,125,113,78,223,164,141,51,217,55,181,21,255,236,168,143,78,91,238,180,113,166,187,97,108,10,252,179,99,254,169,103,117,231,88,185,50,188,171,30,235,80,158,55,224,159,29,243,207,87,150,243,173,235,186,175,113,156,154,95,105,111,111,47,212,243,237,193,193,65,79,207,27,146,228,210,248,103,71,252,83,109,240,215,81,255,84,27,231,93,231,212,214,28,27,122,166,138,142,59,147,223,235,189,220,178,9,254,217,17,255,12,162,
190,169,229,187,182,35,201,55,245,61,3,87,222,245,117,119,61,70,209,252,27,255,52,203,250,151,91,115,125,232,158,243,46,34,223,124,242,228,73,162,111,90,53,106,231,85,205,251,90,22,193,63,189,59,231,67,249,73,84,245,46,77,187,146,213,55,235,199,44,211,57,20,255,244,238,159,106,83,186,229,159,237,158,211,242,250,166,142,253,236,217,179,118,67,161,112,251,225,159,222,253,115,198,229,159,237,24,62,131,111,234,59,175,183,230,248,214,247,7,203,34,248,167,119,255,116,158,63,243,250,75,70,223,212,152,147,237,104,60,224,159,222,109,90,166,12,71,162,254,162,229,60,243,204,169,109,83,223,176,116,229,115,179,78,231,77,249,166,4,255,252,138,3,127,179,19,184,213,111,164,103,239,44,162,119,190,245,172,111,135,138,211,102,223,84,137,240,207,236,118,33,229,87,4,156,125,71,105,207,240,234,7,210,55,139,44,139,56,141,250,166,142,134,127,126,197,156,191,217,9,104,126,139,91,62,22,215,127,164,249,143,83,174,231,202,203,229,155,42,17,254,41,10,72,94,2,177,99,229,103,102,102,106,223,15,214,115,76,204,
247,0,162,190,173,57,219,234,247,155,209,114,224,159,81,34,44,103,33,160,241,75,167,166,81,95,203,179,172,177,121,75,41,7,195,63,83,0,177,57,150,192,184,109,113,190,71,108,235,211,252,244,210,210,204,152,166,9,254,153,70,136,237,73,4,52,223,239,173,177,76,182,46,206,63,117,206,220,48,85,63,105,22,105,203,63,245,77,99,221,103,72,191,241,141,111,252,69,250,157,239,124,231,207,54,111,113,162,216,156,156,127,254,246,183,191,253,23,169,141,255,175,233,79,127,250,211,212,253,126,240,131,31,252,119,253,56,159,127,254,249,95,117,220,229,229,229,212,38,13,218,231,179,184,192,157,211,104,62,134,93,211,56,159,212,122,249,176,158,129,148,54,143,180,229,159,186,247,181,131,180,168,230,43,78,19,215,156,198,89,250,3,190,248,226,139,150,99,233,216,242,209,52,193,63,243,184,194,157,211,202,247,158,153,110,154,202,175,164,122,246,121,100,218,111,218,142,40,143,22,219,103,241,23,252,179,29,212,236,211,6,1,252,179,13,104,236,210,53,2,248,103,215,80,115,160,54,8,224,159,109,64,99,151,174,17,192,63,
187,134,154,3,181,65,0,255,108,3,26,187,116,141,0,254,217,53,212,28,168,13,2,248,103,27,208,216,165,107,4,240,207,174,161,230,64,109,16,192,63,219,128,198,46,93,35,128,127,118,13,53,7,106,131,0,254,217,6,52,118,233,26,1,252,179,107,168,57,80,27,4,122,194,63,109,60,94,104,117,107,81,189,239,114,125,125,157,56,132,41,102,190,169,131,54,56,177,203,253,16,232,9,255,252,242,203,47,91,124,179,238,171,59,59,59,177,254,121,117,117,21,246,247,247,187,246,91,189,31,212,28,181,13,2,93,245,207,111,125,235,91,183,252,37,203,120,190,152,113,156,225,200,200,72,120,113,113,113,203,71,53,63,69,204,185,83,199,31,109,131,19,187,220,15,129,174,250,231,103,159,125,118,203,63,199,199,199,111,249,87,116,133,230,132,50,60,78,213,59,213,26,207,175,115,233,254,254,126,184,185,185,153,52,7,192,209,253,96,230,168,109,18,232,170,127,106,204,187,203,207,52,175,68,146,184,198,221,187,242,201,176,78,239,203,32,189,67,160,171,254,249,189,239,125,207,233,159,186,126,199,137,230,117,54,156,62,84,239,200,32,189,
69,192,155,127,126,243,155,223,140,115,177,198,122,215,123,33,134,171,230,123,242,209,230,231,113,221,67,106,126,124,61,167,215,211,220,225,191,124,83,239,108,35,189,69,192,155,127,126,253,235,95,111,248,97,220,143,233,233,233,68,95,211,188,248,186,31,157,156,156,12,7,7,7,147,210,254,187,97,190,53,207,180,173,139,238,115,101,235,2,211,184,249,41,108,19,82,96,2,222,252,211,234,24,190,123,247,46,206,53,107,207,217,74,227,65,245,110,255,160,169,68,239,6,110,153,190,53,189,48,213,124,1,122,6,210,187,172,122,151,176,221,247,6,109,87,164,0,4,188,250,231,212,212,84,168,249,29,163,146,210,222,147,199,103,229,127,154,35,21,169,6,1,175,254,105,200,66,61,107,175,175,175,215,190,87,163,111,44,233,27,173,9,115,62,254,175,246,201,168,58,63,78,154,34,213,33,224,221,63,13,93,86,127,83,186,127,52,93,48,213,53,57,110,191,51,219,182,108,154,117,78,20,75,138,148,132,192,182,213,163,197,47,178,244,231,36,61,135,71,243,75,88,214,60,60,205,162,126,29,221,79,234,190,81,254,56,103,58,102,202,179,141,
65,168,168,220,151,127,234,184,248,93,69,157,46,71,181,125,250,231,255,217,113,91,206,197,142,101,181,247,232,123,246,8,4,178,16,240,233,159,255,102,7,92,50,221,53,213,253,164,124,81,207,219,199,166,123,166,220,67,26,4,36,23,1,159,254,169,188,16,8,248,36,128,127,250,164,73,94,190,9,224,159,190,137,146,159,79,2,248,167,79,154,228,229,155,0,254,233,155,40,249,249,36,128,127,250,164,73,94,190,9,224,159,190,137,146,159,79,2,248,167,79,154,228,229,155,0,254,233,155,40,249,249,36,128,127,250,164,73,94,190,9,224,159,190,137,146,159,79,2,248,167,79,154,228,229,155,0,254,233,155,40,249,249,36,128,127,250,164,73,94,190,9,224,159,190,137,146,159,79,2,248,167,79,154,228,229,155,0,254,233,155,40,249,249,36,160,111,33,135,205,58,59,59,27,125,125,253,214,178,210,52,239,115,243,91,121,33,16,240,73,64,239,74,182,248,154,230,116,117,205,177,80,119,82,109,139,153,247,85,121,33,16,240,73,96,216,50,107,241,79,45,39,205,39,183,186,186,122,43,253,77,30,202,11,129,128,111,2,154,187,232,150,207,45,47,
47,135,167,167,167,245,211,102,120,118,118,22,174,172,172,220,74,119,179,175,242,64,32,208,9,2,122,231,50,206,239,106,243,27,102,152,227,80,121,32,16,232,20,129,67,203,56,214,71,83,182,105,95,4,2,157,36,160,123,199,19,211,188,62,170,125,134,58,89,48,242,134,192,13,1,205,169,153,231,60,170,180,245,121,56,129,8,129,110,17,152,181,3,105,190,143,184,115,169,190,111,165,52,8,4,238,147,192,3,59,184,230,143,211,60,114,204,37,119,159,150,224,216,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,32,133,128,26,113,254,104,250,187,79,250,250,62,233,27,177,95,246,209,179,177,79,107,255,249,3,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,
0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,160,3,4,30,88,158,195,29,200,151,44,33,0,129,190,62,197,215,132,233,83,211,117,211,93,211,35,211,43,211,48,162,31,108,249,204,244,216,244,208,84,105,183,77,215,77,159,155,206,154,62,52,69,32,0,1,55,1,197,219,180,233,75,211,183,166,138,169,104,156,221,117,89,241,169,184,124,102,170,216,214,49,17,8,84,149,64,191,85,252,177,233,150,233,165,233,93,227,43,239,254,215,118,76,93,43,231,76,137,69,131,128,84,130,192,184,213,82,215,161,78,92,227,242,198,96,61,253,133,149,231,149,233,152,41,2,129,50,18,152,177,74,237,153,214,125,190,168,255,223,89,25,23,77,185,38,26,4,164,167,9,200,
135,231,77,143,76,139,26,111,113,229,122,111,101,158,50,69,32,208,139,4,38,173,208,242,225,56,255,190,211,250,161,161,161,59,237,159,163,92,219,150,118,200,20,129,64,47,16,24,176,66,170,237,255,163,105,219,49,242,240,225,195,112,110,110,46,124,241,226,69,184,179,179,19,190,127,255,62,188,188,188,12,163,242,225,195,135,240,236,236,44,60,62,62,14,15,15,15,195,221,221,221,112,123,123,59,92,95,95,15,231,231,231,195,209,209,209,182,203,208,84,254,43,251,189,108,202,61,169,65,64,10,75,64,237,153,231,166,109,249,252,244,244,116,45,110,78,78,78,162,97,118,167,229,171,171,171,112,111,111,47,92,91,91,171,197,244,192,192,64,91,229,179,122,29,152,62,52,69,32,80,36,2,186,63,83,91,126,110,191,158,157,157,13,183,182,182,156,215,182,59,5,93,194,206,186,102,234,152,83,83,83,185,203,107,117,60,49,165,157,212,32,32,133,32,48,97,165,200,117,205,235,239,239,15,23,23,23,195,163,163,163,132,40,233,206,38,221,183,174,172,172,132,131,131,131,121,98,81,253,149,51,133,160,79,33,170,76,64,247,155,153,251,
241,244,76,247,252,249,243,240,226,226,162,59,193,149,227,40,186,38,170,108,58,55,88,157,178,168,158,111,151,170,108,124,234,126,175,4,158,219,209,179,248,105,248,224,193,131,112,121,121,57,148,143,23,93,78,79,79,195,71,143,30,101,170,215,77,253,231,239,213,10,28,188,106,4,212,6,184,109,154,201,71,39,39,39,107,109,151,69,143,187,104,249,246,247,247,195,140,125,28,26,199,166,177,171,8,4,58,77,64,237,44,26,31,157,26,123,186,215,220,216,216,8,63,126,252,24,117,237,158,89,214,125,242,196,196,68,106,93,141,135,198,175,141,154,34,16,232,20,1,197,222,153,105,170,63,170,77,243,252,252,188,103,226,44,169,160,186,103,126,252,248,113,106,157,141,139,218,69,233,155,48,8,136,119,2,234,83,215,184,200,84,63,124,250,244,105,79,95,243,92,177,168,107,184,158,95,51,212,95,227,91,17,8,248,36,160,231,189,212,190,61,181,177,108,110,110,186,220,183,52,235,116,110,49,22,105,250,196,39,124,242,170,60,129,141,52,159,83,223,153,198,126,149,93,116,29,212,152,184,20,30,122,22,228,62,180,242,97,227,5,192,
74,138,175,133,99,99,99,161,218,236,171,34,122,30,84,155,110,10,23,189,83,140,64,224,46,4,116,31,149,232,103,106,159,47,75,59,75,158,243,135,218,69,213,190,155,194,135,62,137,187,120,95,181,247,149,239,168,95,43,214,199,52,134,185,8,227,199,242,196,141,207,180,26,63,154,196,199,182,29,154,34,16,200,75,64,99,139,53,190,49,214,191,212,214,162,254,233,170,75,134,241,219,122,7,18,129,64,86,2,234,227,59,53,141,141,61,109,211,185,31,9,107,215,127,157,139,18,120,169,221,24,129,64,22,2,153,250,248,86,87,87,9,189,38,2,122,143,195,224,198,169,198,104,51,46,38,139,247,85,59,141,250,248,118,76,227,252,168,182,126,97,97,161,201,243,248,41,2,106,251,77,185,6,110,86,219,181,168,125,6,2,235,105,177,55,51,51,83,186,113,45,190,206,32,41,227,211,244,44,173,243,27,2,1,23,129,101,91,153,120,221,83,31,95,47,188,59,228,43,158,242,230,163,118,224,20,134,122,79,18,129,64,148,128,250,248,244,140,18,235,63,85,237,227,203,27,131,154,187,38,129,227,235,40,120,150,43,79,64,125,124,137,239,174,87,189,143,47,
79,12,106,190,53,227,25,167,226,172,249,246,17,8,136,128,250,248,52,78,49,206,95,106,109,10,244,241,101,143,64,141,137,73,105,135,153,19,120,164,242,4,212,199,167,119,213,98,99,79,219,52,135,38,146,143,128,222,123,76,224,170,54,46,164,218,4,212,199,151,250,254,186,230,188,69,242,19,208,251,87,198,55,78,143,170,237,122,149,175,125,166,62,62,245,39,35,237,17,208,188,193,9,241,167,109,188,151,84,221,48,124,149,226,27,161,238,159,122,121,190,150,246,162,198,239,94,41,115,54,209,15,81,205,248,123,150,22,123,227,227,227,244,241,121,8,69,125,115,34,129,245,106,53,221,175,210,181,214,57,55,181,143,175,136,115,226,122,8,135,174,103,145,210,15,65,63,96,181,66,113,202,170,155,218,199,167,57,216,17,63,4,244,157,23,99,30,167,154,195,10,169,6,1,141,187,79,237,227,59,56,56,240,227,120,228,82,35,144,210,6,163,177,160,72,249,9,12,90,21,233,227,187,167,115,66,74,63,188,250,128,144,242,18,208,56,39,250,248,238,41,246,116,216,145,145,145,184,251,79,173,215,125,9,82,94,2,169,239,241,45,45,45,221,
163,119,150,255,208,122,87,203,220,43,78,103,202,235,122,149,175,89,106,31,159,190,237,67,31,95,103,207,1,122,79,57,33,254,22,42,239,165,229,4,240,52,193,230,53,127,208,183,68,120,143,175,179,177,167,220,245,29,193,4,91,44,150,211,253,42,93,43,141,173,79,236,227,27,30,30,46,228,119,47,59,31,13,221,63,130,198,207,154,61,226,116,165,210,158,90,190,202,107,142,187,212,62,62,181,139,35,221,33,144,18,127,65,249,92,176,178,53,26,177,154,167,246,241,85,225,219,12,221,137,172,108,71,33,254,42,17,143,26,75,159,218,199,247,250,245,235,108,78,67,42,111,4,136,191,210,199,159,222,37,74,237,227,91,91,91,243,230,83,100,148,157,0,241,87,250,248,123,99,53,140,123,190,175,173,167,143,47,123,188,248,78,153,242,173,206,160,244,222,89,238,10,190,76,139,61,250,248,124,71,84,190,252,82,230,196,94,44,183,123,150,186,118,244,241,229,11,133,123,73,77,252,149,50,6,83,231,234,212,184,67,222,227,187,151,144,107,57,40,241,87,186,248,155,176,26,93,155,198,62,243,233,123,144,244,241,181,132,193,189,45,16,127,
165,138,63,245,51,156,37,197,158,222,119,121,251,246,237,189,249,27,7,110,37,64,252,149,42,254,54,147,98,79,219,222,188,121,211,234,0,44,221,43,1,226,175,52,241,167,249,35,98,239,57,181,237,229,203,151,29,245,53,93,87,55,54,54,66,245,105,189,122,245,42,100,44,77,58,110,226,175,52,241,167,239,167,198,198,223,211,167,79,211,157,161,205,20,138,187,184,111,138,104,174,52,226,48,30,44,241,87,138,248,27,177,90,196,190,211,160,119,137,174,175,175,227,157,224,14,91,82,222,159,169,157,15,244,204,201,28,245,110,200,196,95,41,226,47,182,159,93,190,175,111,206,117,66,82,198,110,180,92,139,251,251,251,105,115,117,24,129,248,43,69,252,233,123,1,45,254,94,95,238,212,216,178,60,177,87,47,139,198,218,32,173,4,136,191,158,143,63,205,145,21,123,239,217,137,107,95,59,177,167,24,212,181,248,242,242,178,213,1,43,190,68,252,245,124,252,205,200,183,93,170,247,216,125,75,187,177,87,47,223,206,206,142,239,34,245,116,126,196,159,121,70,111,203,146,21,223,25,127,79,158,60,241,234,155,57,98,239,44,174,76,
234,155,64,254,70,128,248,235,237,224,179,210,47,198,249,186,108,235,75,114,196,222,178,149,39,136,43,19,241,215,106,17,226,207,60,165,183,69,243,41,57,175,127,190,226,47,103,236,137,102,16,87,38,226,143,248,147,131,148,72,102,172,46,206,248,83,223,247,93,165,141,216,19,218,32,174,76,196,95,171,69,184,254,201,93,122,90,198,173,244,206,248,211,250,118,219,63,53,239,238,179,103,207,98,243,141,28,83,247,156,205,18,216,130,115,95,226,143,248,107,118,148,146,252,142,237,255,107,103,220,153,230,221,157,155,155,115,198,143,35,174,162,177,39,164,129,35,93,45,63,226,143,248,147,131,148,76,20,3,206,120,81,159,219,187,119,239,90,141,158,176,244,254,253,251,112,108,108,204,153,151,227,24,174,216,19,218,192,145,150,248,115,112,231,254,83,238,210,243,50,100,53,136,237,131,215,119,198,207,206,206,28,214,255,219,42,189,11,175,177,50,138,87,203,43,139,198,197,158,96,6,113,121,112,253,251,27,115,253,34,254,228,46,165,144,61,171,69,108,220,140,142,142,134,250,222,106,84,244,124,168,49,212,122,39,
62,105,255,166,109,138,243,37,211,36,9,108,163,51,63,226,175,213,2,196,95,146,27,245,212,182,9,43,109,236,53,176,30,15,138,51,189,43,164,239,94,165,124,123,206,21,63,202,95,115,203,164,73,96,9,92,251,135,196,31,241,151,230,60,61,188,61,214,239,227,226,33,199,122,125,55,226,177,105,22,9,44,17,241,215,26,106,206,37,174,127,89,220,169,103,210,60,176,146,238,199,249,254,29,214,31,219,190,234,231,200,42,129,37,36,254,156,17,215,186,146,248,203,234,82,61,147,78,239,67,196,246,71,196,197,69,204,122,221,111,174,155,42,207,60,18,88,98,226,175,53,212,156,75,196,95,30,183,234,153,180,106,15,189,107,12,234,58,58,214,102,141,3,219,207,75,252,37,61,163,230,153,199,77,105,227,202,164,99,228,145,31,254,240,135,177,121,41,158,242,8,241,215,166,135,21,127,55,221,139,6,166,137,223,251,179,237,81,95,82,220,206,154,222,69,2,219,57,154,111,109,57,111,251,11,241,119,23,51,176,111,1,8,60,180,50,168,175,238,192,212,21,139,186,199,60,52,213,183,86,71,77,125,72,96,153,16,127,25,46,132,92,255,124,184,91,
79,229,161,118,148,25,211,145,27,205,251,108,103,187,165,74,96,41,136,63,226,47,213,81,72,208,17,2,129,229,74,252,17,127,29,113,46,50,77,37,16,88,10,226,143,248,75,117,20,18,116,132,64,96,185,18,127,196,95,71,156,139,76,83,9,4,150,130,248,35,254,82,29,133,4,29,33,16,88,174,196,31,241,215,17,231,34,211,84,2,129,165,32,254,136,191,84,71,33,65,71,8,4,150,43,241,71,252,117,196,185,200,52,149,64,96,41,136,63,226,47,213,81,72,208,17,2,129,229,74,252,17,127,29,113,46,50,77,37,16,88,10,226,143,248,75,117,20,18,116,132,64,96,185,18,127,196,95,71,156,139,76,83,9,4,150,130,248,35,254,82,29,133,4,29,33,16,88,174,196,31,241,215,17,231,34,211,84,2,129,165,32,254,136,191,84,71,33,65,71,8,4,150,43,241,71,252,117,196,185,200,52,149,64,96,41,74,27,127,95,126,249,165,179,110,170,179,230,117,204,35,250,70,99,28,43,91,191,96,138,64,32,47,129,192,118,112,250,85,25,230,159,248,201,79,126,226,172,155,234,172,249,85,245,237,154,172,146,52,191,134,229,55,101,138,64,32,47,129,192,118,112,250,104,25,226,
239,151,191,252,165,179,110,245,58,103,253,198,182,190,203,81,223,199,241,95,243,130,116,98,110,2,203,22,41,57,129,192,234,231,244,173,50,196,223,246,246,182,179,110,245,58,235,251,53,105,215,64,109,159,154,154,74,202,231,125,201,125,132,234,117,142,64,96,89,59,125,171,136,241,55,56,56,152,245,118,177,150,46,45,254,84,247,71,143,30,133,250,166,141,75,174,174,174,194,148,231,62,177,211,124,88,8,4,218,33,16,216,78,133,138,191,211,211,83,103,121,234,229,140,139,21,87,252,172,173,173,37,230,85,207,179,191,191,63,92,88,88,8,117,206,81,204,106,63,205,119,150,225,91,55,186,247,212,28,174,8,4,218,33,16,216,78,78,31,189,175,235,159,190,191,22,87,38,173,127,243,230,141,43,212,156,235,102,103,103,19,243,74,58,78,198,109,175,44,29,2,129,118,9,4,182,163,211,71,139,26,127,89,251,13,116,29,205,241,141,68,39,131,56,54,55,235,207,236,63,237,46,6,1,105,155,64,96,123,58,125,175,168,241,167,242,110,109,109,57,175,119,245,149,106,51,81,156,198,213,205,195,122,205,143,76,159,131,65,64,238,68,32,176,
189,157,126,234,51,254,126,251,219,223,214,67,35,245,127,218,253,167,202,171,235,154,158,209,212,62,18,21,125,167,52,165,189,210,89,223,56,14,142,245,23,182,78,223,112,68,32,112,87,2,129,101,224,244,71,159,241,247,227,31,255,56,26,38,177,203,187,187,187,206,242,184,202,57,48,48,16,170,15,65,215,58,125,171,116,120,120,56,235,190,255,225,202,47,195,186,67,75,51,108,138,64,192,7,129,192,50,113,250,172,207,248,251,226,139,47,98,227,45,186,65,223,182,143,43,147,167,245,91,150,143,68,215,176,55,166,106,195,76,59,230,174,165,153,52,69,32,224,147,64,96,153,57,125,207,103,252,125,250,233,167,161,238,11,211,228,252,252,60,75,155,191,179,188,113,245,136,172,63,183,101,125,231,166,89,6,109,97,198,116,209,52,48,221,190,249,191,104,255,103,76,233,95,48,8,72,71,8,4,150,171,211,159,125,198,159,142,49,62,62,30,219,207,173,184,252,240,225,67,237,30,50,174,60,30,214,235,185,109,218,20,129,64,81,8,4,86,144,174,196,159,142,51,52,52,20,174,175,175,215,174,133,106,59,81,204,29,31,31,215,218,51,71,71,
71,157,229,104,42,223,95,155,126,167,165,141,110,63,179,125,219,253,70,169,237,138,64,160,35,4,2,203,53,234,171,181,101,223,215,191,184,227,228,88,255,207,150,246,32,71,122,213,67,253,4,250,46,183,238,49,17,8,20,141,64,96,5,234,133,248,219,110,2,167,118,19,45,159,152,186,218,78,174,108,189,198,68,63,55,141,62,235,217,42,4,2,133,33,16,88,73,138,30,127,174,54,147,102,128,250,22,240,140,169,250,195,185,206,25,4,164,103,8,4,86,210,34,199,159,174,113,60,183,245,140,59,81,208,156,4,2,75,95,212,248,59,182,178,209,246,159,211,160,36,239,41,2,129,149,182,27,241,247,46,238,56,142,245,71,182,78,243,169,60,48,69,32,80,102,2,129,85,174,27,241,55,98,199,209,248,145,53,83,141,57,81,60,94,154,214,219,74,118,236,247,75,211,89,83,4,2,85,33,16,88,69,187,21,127,85,97,74,61,33,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,
148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,64,96,9,137,191,172,180,72,7,1,191,4,2,203,142,248,243,203,148,220,32,144,149,192,51,75,232,140,191,249,249,249,180,207,101,54,182,127,252,248,49,212,183,160,227,242,178,245,124,179,57,171,69,72,87,37,2,143,172,178,206,184,209,183,250,20,87,89,228,224,224,192,153,199,77,222,250,6,24,2,1,8,220,38,48,96,171,98,99,231,205,155,55,89,194,47,156,155,155,139,205,195,242,215,55,251,16,8,64,192,77,224,173,173,118,198,143,174,129,39,
39,39,137,49,248,250,245,107,231,190,77,121,234,59,124,8,4,32,224,38,176,100,171,99,99,104,112,112,176,246,205,232,139,139,139,150,56,60,58,58,10,23,23,23,99,247,187,201,83,223,199,228,27,70,110,238,172,133,128,8,232,30,84,223,66,73,139,165,176,191,191,63,28,30,30,78,77,215,148,151,190,181,130,64,0,2,201,4,158,216,230,60,113,149,37,173,190,109,68,187,103,50,119,182,66,160,78,64,223,0,203,18,87,89,211,232,27,126,8,4,32,144,141,128,238,67,119,77,179,198,87,82,186,229,108,135,36,21,4,32,208,68,64,223,156,221,50,77,138,173,164,109,106,111,209,189,44,2,1,8,180,79,96,206,118,61,52,77,138,181,230,109,215,150,118,211,116,212,20,129,0,4,252,16,152,176,108,20,87,251,166,167,166,245,152,211,152,150,99,83,221,175,174,154,210,199,96,16,16,8,116,152,128,238,79,137,181,14,67,38,123,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,129,98,18,248,127,1,0,0,0,255,255,3,0,74,146,198,176);



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

else if (xname='ver')                 then result:='2.00.077'
else if (xname='date')                then result:='19may2026'
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

tepREADME20           :m( mtep_README20        );
tepLicense20          :m( mtep_License20       );
tepScrollDown20       :m( mtep_ScrollDown20    );
tepMask20             :m( mtep_Mask20          );
tepMouseDialog20      :m( mtep_MouseDialog20   );
tepThemesDialog20     :m( mtep_ThemesDialog20  );
tepArrow20            :m( mtep_Arrow20         );
tepHand20             :m( mtep_Hand20          );
tepBackground20       :m( mtep_background20    );

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

//## tmanagebackground #########################################################

constructor tmanagebackground.create;
var
   p:longint32;
   a:pointer;

begin

//self
if classnameis('tmanagebackground') then track__inc(satOther,1);
inherited create;

//init
iundoinfo   :=str__new8;
mundo__init( iundoinfo ,high(ilist[0].dslot) + 1 );

icom        :=com__create( CLSID_DesktopWallpaper ) as IDesktopWallpaper;
icount      :=frcrange32( monitors__count ,1 ,high(ilist)+1 );

for p:=0 to pred(icount) do xinititem(p);

end;

destructor tmanagebackground.destroy;
var
   p:longint32;

begin
try

//free
for p:=0 to pred(icount) do xfreeitem(p);

str__free(@iundoinfo);

//self
inherited destroy;
if classnameis('tmanagebackground') then track__inc(satOther,-1);

except;end;
end;

function tmanagebackground.canmode(const xmode:longint32):boolean;
begin

result      :=(xmode>=0) and (xmode<=wm_max);

end;

function tmanagebackground.xtempfile(const xindex:longint):string;//19may2026
begin//one temp file per monitor

//app specific path cannot be shared with system under MSIX, even for full trust app mode
//was: result      :=app__foldersettings(true) + 'background'+intstr32(frcrange32(xindex,0,pred(icount)))+'.bmp';

//confirmed -> io__wintemp CAN be shared with system under MSIX full trust app mode - 19may2026
result      :=io__wintemp + 'temp-background'+intstr32(frcrange32(xindex,0,pred(icount)))+'.bmp';

end;

procedure tmanagebackground.xinititem(const xindex:longint32);
var
   p:longint;

begin

//check
if (xindex<0) or (xindex>=icount) then exit;

//get
with ilist[ xindex ] do
begin

dlast                 :='';
wlast                 :=filename[ xindex ];

//check if currently set background is ours, if so, load the image into RAM and ignore the filename
if strmatch( wlast ,xtempfile( xindex ) ) then
   begin

   dlast              :=io__fromfilestr2( xtempfile( xindex ) );
   wlast              :='';

   end;

for p:=0 to high(dslot) do
begin

dslot[p]              :='';
wslot[p]              :='';

end;//p

end;//with

end;

procedure tmanagebackground.xfreeitem(const xindex:longint32);
begin

//check
if (xindex<0) or (xindex>=icount) then exit;

end;

function tmanagebackground.getfilename(xindex:longint):widestring;
var
   vbuf:array[0..max_path] of char;

begin

//range check
if (xindex<0) or (xindex>=icount) then
   begin

   result   :='';

   end

//modern access
else if (icom<>nil) then
   begin

   result   :=widestring( icom.getwallpaper( icom.GetMonitorDevicePathAt( frcrange32(xindex,0,pred(icount)) ) ) );

   end

//fallback access
else if win____SystemParametersInfo( 115, sizeof(vbuf), @vbuf, 0 ) then//115 = 0x0073 = GetWallpaper
   begin

   result   :=string(vbuf);

   end
else begin

   result   :='';

   end;

end;

procedure tmanagebackground.setfilename(xindex:longint;x:widestring);
var
   v:string;

begin
try

//range check
if (xindex<0) or (xindex>=icount) then
   begin

   //nil

   end

//modern access
else if (icom<>nil) then
   begin

   icom.setwallpaper( icom.GetMonitorDevicePathAt( xindex ) ,pwidechar(x) );

   end

//fallback access -> Works on Windows 95 - 15may2026
else begin

   v        :=string(x);
   win____SystemParametersInfo( 20, 0, pchar(v), 1 or 2 );//20 = 0x0014 = SetWallpaper | 1=SPIF_UPDATEINIFILE or 2=SPIF_SENDWININICHANGE

   end;

except;end;
end;

function tmanagebackground.xfromstr(const xindex:longint;const ddata:string;wdata:widestring):boolean;
var
   a:tbasicimage;
   b:tstr8;
   e:string;

   procedure s;
   begin

   result             :=true;
   filename[ xindex ] :=wdata;

   end;

begin

//defaults
result      :=false;
a           :=nil;
b           :=nil;

//check
if (xindex<0) or (xindex>=icount) then exit;

try

//use image data
if (ddata<>'') then
   begin

   wdata :=xtempfile(xindex);

   a     :=misimg24(1,1);//24bit image -> compatible with Windows 95+ - 15may2026
   b     :=str__new8;
   b.sadd( ddata );

   mis__fromdata( a ,@b ,e );

   mis__tofile( a ,string(wdata) ,io__readfileext_low(string(wdata)) ,e );//writes a 24-bit Bitmap

   s;

   end

//use filename
else begin

   s;

   end;

except;end;

//free
if (a<>nil) then freeobj(@a);
if (b<>nil) then str__free(@b);

end;

function tmanagebackground.canundo:boolean;
begin

result:=mundo__canundo( iundoinfo );

end;

function tmanagebackground.undo:boolean;
var
   p,i:longint32;
   lw,sw:widestring;
   ld,sd:string;

begin

//defaults
result      :=canundo;

//get
if result and mundo__undo( iundoinfo ,i ) then
   begin

   for p:=0 to pred(icount) do
   begin

   sd                        :=ilist[p].dslot[i];
   sw                        :=ilist[p].wslot[i];

   ld                        :=ilist[p].dlast;
   lw                        :=ilist[p].wlast;

   ilist[p].dslot[i]         :=ld;
   ilist[p].wslot[i]         :=lw;

   ilist[p].dlast            :=sd;
   ilist[p].wlast            :=sw;

   xfromstr( p ,sd ,sw );

   end;//p

   end;

end;

function tmanagebackground.canredo:boolean;
begin

result:=mundo__canredo( iundoinfo );

end;

function tmanagebackground.redo:boolean;
var
   p,i:longint32;
   sd,ld:string;
   sw,lw:widestring;

begin

//defaults
result      :=canredo;

//get
if result and mundo__redo( iundoinfo ,i ) then
   begin

   for p:=0 to pred(icount) do
   begin

   sd                        :=ilist[p].dslot[i];
   sw                        :=ilist[p].wslot[i];

   ld                        :=ilist[p].dlast;
   lw                        :=ilist[p].wlast;

   ilist[p].dslot[i]         :=ld;
   ilist[p].wslot[i]         :=lw;

   ilist[p].dlast            :=sd;
   ilist[p].wlast            :=sw;

   xfromstr( p ,sd ,sw );

   end;//p

   end;

end;

procedure tmanagebackground.pageBackground;
begin

//Windows 10+
if not io__runwait1('ms-settings:personalization-background','',1) then
   begin

   //Windows 95+
   io__runwait1('control','desk.cpl',1);

   end;

end;

function tmanagebackground.canfromdata(const xmode:longint32):boolean;
begin

result      :=canmode(xmode);

end;

function tmanagebackground.fromdata(const xmode:longint32;const xdata:pobject):boolean;
var
   p,i:longint32;

begin

//defaults
result      :=false;

//check
if not canfromdata(xmode) then exit;
if not str__lock( xdata ) then exit;

try

//get
if io__imageExtSupported( io__anyformatb( xdata ) ) then
   begin

   //init
   result   :=true;
   i        :=mundo__newslot( iundoinfo );

   //get
   for p:=0 to pred(icount) do
   begin

   if (xmode=wm_all) or ((xmode=wm_one) and (app__gui<>nil) and (app__gui.form__monitorindex=p)) then
      begin

      xfromstr( p ,str__text(xdata) ,'' );

      ilist[p].dslot[i]      :=ilist[p].dlast;
      ilist[p].wslot[i]      :=ilist[p].wlast;

      ilist[p].dlast         :=str__text(xdata);
      ilist[p].wlast         :='';

      end
   else begin

      ilist[p].dslot[i]      :=ilist[p].dlast;
      ilist[p].wslot[i]      :=ilist[p].wlast;

      end;

   end;//p

   end;

except;end;

//free
str__uaf( xdata );

end;

function tmanagebackground.xisfilename(const x:string):boolean;
begin

result      :=(strcopy1(x,2,2)=':\');

end;

function tmanagebackground.canfromfile(const xmode:longint32):boolean;
begin

result      :=canmode( xmode );

end;

function tmanagebackground.fromfile(const xmode:longint32;const xfilename:string):boolean;
begin

case canfromfile(xmode) and xisFilename(xfilename) of
true:result :=fromstr( xmode ,io__fromfilestr2(xfilename) );
else result :=false;
end;//case

end;

function tmanagebackground.canfromstr(const xmode:longint32):boolean;
begin

result      :=canfromdata( xmode );

end;

function tmanagebackground.fromstr(const xmode:longint32;const xdata:string):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromstr( xmode )  then exit;
if (xdata='')               then exit;

try

//init
a           :=str__new8;
a.sadd( xdata );


//get
result      :=fromdata( xmode ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;

function tmanagebackground.canfromrec(const xmode:longint32):boolean;
begin

result      :=canfromdata( xmode );

end;

function tmanagebackground.fromrec(const xmode:longint32;const xdata:array of byte):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromrec( xmode )  then exit;
if (low(xdata)<>0)          then exit;

try

//init
a           :=str__new8;
a.aadd( xdata );


//get
result      :=fromdata( xmode ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;


//## tmanagecursor #############################################################

constructor tmanagecursor.create;
var
   p:longint32;

begin

//self
if classnameis('tmanagecursor') then track__inc(satOther,1);
inherited create;

//create
iundoinfo   :=str__new8;
mundo__init( iundoinfo ,high(ilist[0].undoslot)+1 );

for p:=0 to high(ilist) do xinititem(p);

end;

destructor tmanagecursor.destroy;
var
   p:longint32;

begin
try

//free
for p:=0 to high(ilist) do xfreeitem(p);

str__free(@iundoinfo);

//self
inherited destroy;
if classnameis('tmanagecursor') then track__inc(satOther,-1);

except;end;
end;

function tmanagecursor.xfinddefault(const xindex:longint32):string;//11may2026

   procedure s(const xdata:array of byte);
   var
      dkey:hkey;
      dext,v,e:string;
      a:tstr8;
      vbuf:array[0..max_path] of char;

      function m(const n:string):boolean;
      begin

      result:=strmatch(n,dext);

      end;

   begin

   //defaults
   a        :=nil;

   //check
   if (low(xdata)<>0) then exit;

   try

   //init
   a        :=str__new8;

   //from registry based filename first
   if (ilist[xindex].reg_name<>'') then
      begin

      v     :=reg__readval(0,'Control Panel\Cursors\'+ilist[xindex].reg_name,false);

      //decode shortened filenames -> e.g. "%SystemRoot%\cursors\arrow_eoa.cur' - 11may2026
      if (v<>'') then
         begin

         low__cls(@vbuf,sizeof(vbuf));

         case (win____ExpandEnvironmentStrings( pchar(v) ,@vbuf, sizeof(vbuf) )>=1) of
         true:v:=string(vbuf);
         else v:='';
         end;//case

         end;

      //read cursor data
      if (v<>'') then
         begin

         io__fromfile64( v ,@a ,e );

         //check format
         dext         :=io__anyformatb( @a );

         case m('ico') or m('cur') or m('ani') of//ico is required - 11may2026
         true:;//OK
         else a.clear;//discard - wrong format
         end;//case

         end;

      end;

   //fallback -> get cursor data from built-in content - 11may2026
   if (a.len32<=0) then
      begin

      a.aadd( xdata );

      if strmatch('zip',io__anyformatb(@a)) then
         begin

         low__decompress( @a );

         end;

      end;

   //set
   result   :=a.text;

   except;end;

   //free
   freeobj(@a);

   end;

begin

//defaults
result      :='';

//get
case xindex of

ci_arrow    :begin

   case (cursor__size<=32) of
   true:s(file__arrow_small_cur);
   else s(file__arrow_eoa_cur);
   end;//case

   end;

ci_hand     :begin

   case (cursor__size<=32) of
   true:s(file__hand_small_cur);
   else s(file__link_eoa_cur);
   end;//case

   end;

end;//case

end;

procedure tmanagecursor.mousePropertiesDialog;
begin

io__runwait1('control','main.cpl',1);//Win95-Win11

end;

procedure tmanagecursor.mouseSettingsDialog;
begin

if not io__runwait1('ms-settings:easeofaccess-mousepointer','',1) then
   begin

   if (app__gui<>nil) then app__gui.poperror('Not Found','Option not available on this operating system version');

   end;

end;

function tmanagecursor.xfindOCRIndex(const xindex:longint32):longint32;
begin

case xindex of
ci_arrow              :result:=ocr_normal;
ci_hand               :result:=ocr_hand;
else                   result:=ocr_normal;
end;//case

end;

function tmanagecursor.xfindREGname(const xindex:longint32):string;
begin

case xindex of
ci_arrow              :result:='Arrow';
ci_hand               :result:='Hand';
else                   result:='Arrow';
end;//case

end;

procedure tmanagecursor.xinititem(const xindex:longint32);
var
   p:longint;

begin

//check
if not can(xindex) then exit;

//get
with ilist[ xindex ] do
begin

for p:=0 to high(undoslot) do
begin

undoslot[p]           :='';

end;//p

ocr_index             :=xfindOCRIndex   ( xindex );
res_name              :=makeintresource ( ocr_index );
reg_name              :=xfindREGname    ( xindex );

//default cursor
lastdata              :=xfindDefault( xindex );

end;//with

end;

procedure tmanagecursor.xfreeitem(const xindex:longint32);
begin

//check
if not can(xindex) then exit;

end;

function tmanagecursor.xfromstr(const xindex:longint;const xdata:string):boolean;
var
   df:string;

begin

//defaults
result      :=false;

//get
if can(xindex) and (xdata<>'') then
   begin

   //write cursor to file
   df       :=app__folderSettings(true) + 'cursor.cur';

   //write to file
   if io__tofilestr2( df ,xdata ) then
      begin

      //read from file
      result:=win____SetSystemCursor( win____LoadCursorFromFile( pchar(df) ) ,ilist[xindex].ocr_index );

      end;

   //remove temp file
   io__remfile( df );

   end;

end;

function tmanagecursor.can(const xindex:longint32):boolean;
begin

result      :=(xindex>=0) and (xindex<=high(ilist));

end;

function tmanagecursor.canreset:boolean;
begin

result      :=true;

end;

function tmanagecursor.reset:boolean;
var
   p:longint;

begin

for p:=0 to ci_max do
begin

fromstr( p , xfinddefault(p) );

end;//p

end;

function tmanagecursor.canundo:boolean;
begin

result      :=mundo__canundo( iundoinfo );

end;

function tmanagecursor.undo:boolean;
var
   p,i:longint32;
   s,d:string;

begin

//defaults
result      :=canundo;

//get
if result and mundo__undo( iundoinfo ,i ) then
   begin

   for p:=0 to ci_max do
   begin

   s                         :=ilist[p].undoslot[i];
   d                         :=ilist[p].lastdata;

   ilist[p].undoslot[i]      :=d;
   ilist[p].lastdata         :=s;

   xfromstr( p ,s );

   end;//p

   end;

end;

function tmanagecursor.canredo:boolean;
begin

result      :=mundo__canredo( iundoinfo );

end;

function tmanagecursor.redo:boolean;
var
   p,i:longint32;
   s,d:string;

begin

//defaults
result      :=canredo;

//get
if result and mundo__redo( iundoinfo ,i ) then
   begin

   for p:=0 to ci_max do
   begin

   s                         :=ilist[p].undoslot[i];
   d                         :=ilist[p].lastdata;

   ilist[p].undoslot[i]      :=d;
   ilist[p].lastdata         :=s;

   xfromstr( p ,s );

   end;//p

   end;

end;

function tmanagecursor.canfromdata(const xindex:longint32):boolean;
begin

result      :=can(xindex);

end;

function tmanagecursor.fromdata(const xindex:longint32;const xdata:pobject):boolean;
var
   dext:string;
   p,i:longint32;

   function m(n:string):boolean;
   begin

   result   :=strmatch( n ,dext );

   end;

begin

//defaults
result      :=false;

//check
if not canfromdata(xindex) then exit;
if not str__lock( xdata )  then exit;

try

//check format -> empty data -> default cursor from "xfinddefault()"
case (str__len32(xdata)=0) of
true:dext:='cur';
else dext:=io__anyformatb( xdata );
end;//case

//get
if m('ico') or m('cur') or m('ani') then
   begin

   result   :=xfromstr( xindex ,str__text(xdata) );

   if result then
      begin

      i                         :=mundo__newslot( iundoinfo );

      for p:=0 to ci_max do
      begin

      if (p=xindex) then
         begin

         ilist[p].undoslot[i]   :=ilist[p].lastdata;
         ilist[p].lastdata      :=str__text(xdata);

         end
      else begin

         ilist[p].undoslot[i]   :=ilist[p].lastdata;

         end;

      end;//p

      end;

   end;

except;end;

//free
str__uaf( xdata );

end;

function tmanagecursor.xisfilename(const x:string):boolean;
begin

result      :=(strcopy1(x,2,2)=':\');

end;

function tmanagecursor.canfromfile(const xindex:longint32):boolean;
begin

result      :=can(xindex);

end;

function tmanagecursor.fromfile(const xindex:longint32;const xfilename:string):boolean;
begin

case canfromfile(xindex) and xisFilename(xfilename) of
true:result :=fromstr( xindex ,io__fromfilestr2(xfilename) );
else result :=false;
end;//case

end;

function tmanagecursor.canfromstr(const xindex:longint32):boolean;
begin

result      :=canfromdata( xindex );

end;

function tmanagecursor.fromstr(const xindex:longint32;const xdata:string):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromstr( xindex ) then exit;
if (xdata='')               then exit;

try

//init
a           :=str__new8;
a.sadd( xdata );


//get
result      :=fromdata( xindex ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;

function tmanagecursor.canfromrec(const xindex:longint32):boolean;
begin

result      :=canfromdata( xindex );

end;

function tmanagecursor.fromrec(const xindex:longint32;const xdata:array of byte):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromrec( xindex ) then exit;
if (low(xdata)<>0)          then exit;

try

//init
a           :=str__new8;
a.aadd( xdata );


//get
result      :=fromdata( xindex ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;


//## tarchive ##################################################################
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
if classnameis('tarchive') then track__inc(satOther,1);
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
ishowmore                    :=true;

imaskMode                    :=mm_all;
ilastmaskmode                :=-1;
imaskCustom                  :='';
imaskCustom2                 :='';

ilastfiletype                :=ft_binary;
ilastfilename                :='?';//force system to update at least once
ilastfileext                 :='';
ilastfilesysOK               :=false;
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

add('',tepDownward20,0,'more','Show More|Show additional options');

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


icursorvsep1          :=xhigh.nbreak(10);
icursorbar            :=xhigh.ntoolbar('');

icursor               :=nil;//create on demand
ibackground           :=nil;//create on demand

with icursorbar do
begin

maketitle3('Cursor',false,false);

normal                :=false;

add('Set as Arrow (Select)',tepArrow20,0,'cursor.setarrow',
 'Set as Arrow (Select)'+
 '|Use the currently previewed cursor below for your Arrow (Normal Select) mouse pointer.'+
 '|*|Note:|Changes are not permanent and will be lost the next time your computer reboots.  '+
 'To make the cursor permanent, click the "Mouse Properties" button (further right on toolbar) and customise manually under the "Pointers" tab.'+
 '');

add('Set as Hand (Link)',tepHand20,0,'cursor.sethand',
 'Set as Hand (Link)'+
 '|Use the currently previewed cursor below for your Hand (Link) mouse pointer.'+
 '|*|Note:|Changes are not permanent and will be lost the next time your computer reboots.  '+
 'To make the cursor permanent, click the "Mouse Properties" button (further right on toolbar) and customise manually under the "Pointers" tab.'+
 '');

add('Redo',tepRedo20,0,'cursor.redo','Cursor|Redo last cursor change');

add('Undo',tepUndo20,0,'cursor.undo','Cursor|Undo last cursor change');

add('Mouse Properties',tepMouseDialog20,0,'cursor.mouseproperties',
 'Mouse Properties Dialog'+
 '|Show the Windows "Mouse Properties" dialog to make permanent changes to your mouse pointer (cursor).'+
 '|*|A cursor customised using this manual method is permanent, and will remain customised even after your computer reboots.'+
 '|*|'+
 'Process:'+
 '|1. Click the "Mouse Properties" button to begin'+
 '|2. Select the "Pointers" tab'+
 '|3. Select the cursor to change, e.g. "Normal Select" (Arrow)'+
 '|4. Click the "Browse" button'+
 '|5. Navigate to your cursor file, select it, and click "Open"'+
 '|6. Click "OK" to set your cursor and close the dialog'+
 '');

add('Mouse & Touch',tepMouseDialog20,0,'cursor.mousesettings',
 'Mouse and Touch Settings'+
 '|Show the Windows "Mouse pointer and touch" settings page, where you can adjust the size of your mouse pointer (cursor).'+
 '|*|Note:'+
 '|This option is only available for Windows 10 and 11.'+
 '');

end;

ibackgroundbar        :=xhigh.ntoolbar('');

with ibackgroundbar do
begin

maketitle3('Background',false,false);

normal                :=false;

add('Set This Monitor',tepBackground20,0,'background.setone',
 'Set This Monitor'+
 '|Use the currently previewed image below as this monitor''s Desktop Background Picture'+
 '');

add('Set All Monitors',tepBackground20,0,'background.setall',
 'Set All Monitors'+
 '|Use the currently previewed image below as the Desktop Background Picture for all monitors'+
 '');

add('Redo',tepRedo20,0,'background.redo','Background|Redo last background change');

add('Undo',tepUndo20,0,'background.undo','Background|Undo last background change');

add('Personalisation',tepThemesDialog20,0,'background.background',
 'Personalisation'+
 '|Show the Windows "Personalisation > Background" settings page for more background picture options, or the "Display Properties" dialog window for older operating system versions.'+
 '');

end;

icursorvsep2          :=xhigh.nbreak(10);


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
icursorbar.onclick    :=__onclick;
ibackgroundbar.onclick:=__onclick;
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

freeobj(@icursor);
freeobj(@ibackground);

//turn off temp cursor - 06may2026
cursor__untemp;

//self
inherited destroy;
if classnameis('tarchive') then track__inc(satOther,-1);

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
   ipic8.visible             :=(v=ft_pic8);
   iimage.visible            :=(v=ft_image);
   itext.visible             :=(v=ft_text);

   //midi
   imidilist.visible         :=(v=ft_midi);
   imidivol.visible          :=(v=ft_midi);
   imididevice.visible       :=(v=ft_midi);
   ijumpbar.visible          :=(v=ft_midi);
   ijump.visible             :=(v=ft_midi);

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

      s('');//set later -> image preview panel has a slight delay before informaation is avaiable, so set hint later in xupdatebuttons

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
ilastfilesysOK        :=(xnewfilename<>'') and strmatch(xnewfilename,isystem__about) or strmatch(xnewfilename,isystem__license) or strmatch(xnewfilename,isystem__readme);

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
   else if cursor__formatSupported( ilastfileext   ) then ihelp('cursor'  )
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
b  ('showmore'       ,ishowmore          );

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

//show mode
ishowmore   :=a.bdef('showmore',true );

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

//cursor support ---------------------------------------------------------------

else if m('cursor.setarrow') then
   begin

   if (icursor<>nil) then icursor.fromdata(ci_arrow,@ilastfiledata);

   end

else if m('cursor.sethand') then
   begin

   if (icursor<>nil) then icursor.fromdata(ci_hand,@ilastfiledata);

   end

else if m('cursor.undo') then
   begin

   if (icursor<>nil) then icursor.undo;

   end

else if m('cursor.redo') then
   begin

   if (icursor<>nil) then icursor.redo;

   end

else if m('cursor.reset') then
   begin

   if (icursor<>nil) then icursor.reset;

   end

else if m('cursor.mouseproperties') then
   begin

   if (icursor<>nil) then icursor.mousePropertiesDialog;

   end

else if m('cursor.mousesettings') then
   begin

   if (icursor<>nil) then icursor.mouseSettingsDialog;

   end


//background support -----------------------------------------------------------

else if m('background.setall') then
   begin

   if (ibackground<>nil) then ibackground.fromdata(wm_all,@ilastfiledata);

   end

else if m('background.setone') then
   begin

   if (ibackground<>nil) then ibackground.fromdata(wm_one,@ilastfiledata);

   end

else if m('background.undo') then
   begin

   if (ibackground<>nil) then ibackground.undo;

   end

else if m('background.redo') then
   begin

   if (ibackground<>nil) then ibackground.redo;

   end

else if m('background.background') then
   begin

   if (ibackground<>nil) then ibackground.pageBackground;

   end

else if m('more') then
   begin

   ishowmore:=not ishowmore;

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
   xok,xisCursor,xisBackground,bol1,xmustRealign:boolean;

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
xiscursor                       :=(ft=ft_image) and cursor__formatSupported( ilastfileext );
xisbackground                   :=(ft=ft_image) and (not cursor__formatSupported( ilastfileext ) );


//more -------------------------------------------------------------------------

//store
bol1                      :=icursorbar.visible or ibackgroundbar.visible;

//cursor support
icursorbar.visible        :=(not ilastfilesysOK) and ishowmore and xiscursor;
ibackgroundbar.visible    :=(not ilastfilesysOK) and ishowmore and xisbackground;

icursorvsep1.visible      :=icursorbar.visible or ibackgroundbar.visible;
icursorvsep2.visible      :=icursorbar.visible or ibackgroundbar.visible;

//auto-create
if icursorbar.visible and (icursor=nil) then
   begin

   icursor         :=tmanagecursor.create;

   end;

if ibackgroundbar.visible and (ibackground=nil) then
   begin

   ibackground     :=tmanagebackground.create;

   end;

//update gui
if (bol1<>(icursorbar.visible or ibackgroundbar.visible)) then
   begin

   xmustRealign:=true;

   end;


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

//.mode -> for format specific toolbars
bvisible2['more']               :=(not ilastfilesysOK) and (xiscursor or xisbackground);
bmarked2['more']                :=ishowmore;

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


//cursorbar --------------------------------------------------------------------

xok                             :=xisCursor and (icursor<>nil);

with icursorbar do
begin

benabled2['cursor.setarrow']    :=xok;
benabled2['cursor.sethand']     :=xok;
benabled2['cursor.undo']        :=xok and icursor.canundo;
benabled2['cursor.redo']        :=xok and icursor.canredo;
benabled2['cursor.reset']       :=xok and icursor.canreset;

end;


//backgroundbar ----------------------------------------------------------------

xok                             :=xisbackground and (ibackground<>nil);

with ibackgroundbar do
begin

benabled2['background.setall']  :=xok;
bvisible2['background.setall']  :=xok and (monitors__count>=2);//19may2026

benabled2['background.setone']  :=xok;

benabled2['background.undo']    :=xok and ibackground.canundo;
benabled2['background.redo']    :=xok and ibackground.canredo;

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

result:=(x<>'') and ( m('cur') or m('ani') );

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

//can close app safely -> tell system it's safe to shutdown now - 15may2026, 09may2026
if app__closeinited then
   begin

   //prompt App Clean Up (not when an MSIX app) -> removes app's storage folder and its contents
   if (not system_msix) and (not gui.popqueryex2('Clean Up','Keep app settings for next time?','No - Discard them now','Yes - Keep them',500,200,0,60)) then
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
