-- module
local KeyMapModule = {}

---@class KeyMaps
local KeyMaps = {}

--------------------------------------------------------------------
KeyMaps.CandyEditor = {
	["lalt"]        = 205 ;
	["pause"]      = 178 ;
	["menu"]       = 255 ;
	[","]          = 44 ;
	["'"]          = 39 ;
	["0"]          = 48 ;
	["4"]          = 52 ;
	["8"]          = 56 ;
	["sysreq"]     = 180 ;
	["@"]          = 64 ;
	["return"]     = 174 ;
	["7"]          = 55 ;
	["\\"]         = 92 ;
	["insert"]     = 176 ;
	["d"]          = 68 ;
	["h"]          = 72 ;
	["l"]          = 76 ;
	["p"]          = 80 ;
	["t"]          = 84 ;
	["x"]          = 88 ;
	["right"]      = 190 ;
	["lmeta"]       = 204 ;
	["escape"]     = 170 ;
	["home"]       = 186 ;
	["`"]          = 96 ;
	["space"]      = 32 ;
	["3"]          = 51 ;
	["backspace"]  = 173 ;
	["pagedown"]   = 193 ;
	["/"]          = 47 ;
	[";"]          = 59 ;
	["scrolllock"] = 208 ;
	["["]          = 91 ;
	["c"]          = 67 ;
	["z"]          = 90 ;
	["g"]          = 71 ;
	["lshift"]      = 202 ;
	["k"]          = 75 ;
	["o"]          = 79 ;
	["s"]          = 83 ;
	["w"]          = 87 ;
	["delete"]     = 177 ;
	["down"]       = 191 ;
	["."]          = 46 ;
	["2"]          = 50 ;
	["6"]          = 54 ;
	[":"]          = 58 ;
	["b"]          = 66 ;
	["f"]          = 70 ;
	["j"]          = 74 ;
	["pageup"]     = 192 ;
	["up"]         = 189 ;
	["n"]          = 78 ;
	["r"]          = 82 ;
	["v"]          = 86 ;
	["f12"]        = 229 ;
	["f13"]        = 230 ;
	["f10"]        = 227 ;
	["f11"]        = 228 ;
	["f14"]        = 231 ;
	["f15"]        = 232 ;
	["lctrl"]       = 203 ;
	["f1"]         = 218 ;
	["f2"]         = 219 ;
	["f3"]         = 220 ;
	["f4"]         = 221 ;
	["f5"]         = 222 ;
	["f6"]         = 223 ;
	["f7"]         = 224 ;
	["f8"]         = 225 ;
	["f9"]         = 226 ;
	["tab"]        = 171 ;
	["numlock"]    = 207 ;
	["end"]        = 187 ;
	["-"]          = 45 ;
	["1"]          = 49 ;
	["5"]          = 53 ;
	["9"]          = 57 ;
	["="]          = 61 ;
	["]"]          = 93 ;
	["a"]          = 65 ;
	["e"]          = 69 ;
	["i"]          = 73 ;
	["m"]          = 77 ;
	["q"]          = 81 ;
	["u"]          = 85 ;
	["y"]          = 89 ;
	["left"]       = 188 ;
}


--------------------------------------------------------------------
KeyMaps.SDL = {
	['unknown']            = 0x000;
	['a']                  = 0x004;
	['b']                  = 0x005;
	['c']                  = 0x006;
	['d']                  = 0x007;
	['e']                  = 0x008;
	['f']                  = 0x009;
	['g']                  = 0x00A;
	['h']                  = 0x00B;
	['i']                  = 0x00C;
	['j']                  = 0x00D;
	['k']                  = 0x00E;
	['l']                  = 0x00F;
	['m']                  = 0x010;
	['n']                  = 0x011;
	['o']                  = 0x012;
	['p']                  = 0x013;
	['q']                  = 0x014;
	['r']                  = 0x015;
	['s']                  = 0x016;
	['t']                  = 0x017;
	['u']                  = 0x018;
	['v']                  = 0x019;
	['w']                  = 0x01A;
	['x']                  = 0x01B;
	['y']                  = 0x01C;
	['z']                  = 0x01D;
	['1']                  = 0x01E;
	['2']                  = 0x01F;
	['3']                  = 0x020;
	['4']                  = 0x021;
	['5']                  = 0x022;
	['6']                  = 0x023;
	['7']                  = 0x024;
	['8']                  = 0x025;
	['9']                  = 0x026;
	['0']                  = 0x027;
	['return']             = 0x028;
	['escape']             = 0x029;
	['backspace']          = 0x02A;
	['tab']                = 0x02B;
	['space']              = 0x02C;
	['-']                  = 0x02D;
	['=']                  = 0x02E;
	['{']                  = 0x02F;
	['}']                  = 0x030;
	['\\']                 = 0x031;
	['nonuslash']          = 0x032;
	[';']                  = 0x033;
	['\'']                 = 0x034;
	['`']                  = 0x035;
	[',']                  = 0x036;
	['.']                  = 0x037;
	['/']                  = 0x038;
	['capslock']           = 0x039;
	['f1']                 = 0x03A;
	['f2']                 = 0x03B;
	['f3']                 = 0x03C;
	['f4']                 = 0x03D;
	['f5']                 = 0x03E;
	['f6']                 = 0x03F;
	['f7']                 = 0x040;
	['f8']                 = 0x041;
	['f9']                 = 0x042;
	['f10']                = 0x043;
	['f11']                = 0x044;
	['f12']                = 0x045;
	['printscreen']        = 0x046;
	['scrolllock']         = 0x047;
	['pause']              = 0x048;
	['insert']             = 0x049;
	['home']               = 0x04A;
	['pageup']             = 0x04B;
	['delete']             = 0x04C;
	['end']                = 0x04D;
	['pagedown']           = 0x04E;
	['right']              = 0x04F;
	['left']               = 0x050;
	['down']               = 0x051;
	['up']                 = 0x052;
	['numlockclear']       = 0x053;
	['kp_divide']          = 0x054;
	['kp_multiply']        = 0x055;
	['kp_minus']           = 0x056;
	['kp_plus']            = 0x057;
	['kp_enter']           = 0x058;
	['kp_1']               = 0x059;
	['kp_2']               = 0x05A;
	['kp_3']               = 0x05B;
	['kp_4']               = 0x05C;
	['kp_5']               = 0x05D;
	['kp_6']               = 0x05E;
	['kp_7']               = 0x05F;
	['kp_8']               = 0x060;
	['kp_9']               = 0x061;
	['kp_0']               = 0x062;
	['kp_period']          = 0x063;
	['nonusbackslash']     = 0x064;
	['application']        = 0x065;
	['power']              = 0x066;
	['kp_equals']          = 0x067;
	['f13']                = 0x068;
	['f14']                = 0x069;
	['f15']                = 0x06A;
	['f16']                = 0x06B;
	['f17']                = 0x06C;
	['f18']                = 0x06D;
	['f19']                = 0x06E;
	['f20']                = 0x06F;
	['f21']                = 0x070;
	['f22']                = 0x071;
	['f23']                = 0x072;
	['f24']                = 0x073;
	['execute']            = 0x074;
	['help']               = 0x075;
	['menu']               = 0x076;
	['select']             = 0x077;
	['stop']               = 0x078;
	['again']              = 0x079;
	['undo']               = 0x07A;
	['cut']                = 0x07B;
	['copy']               = 0x07C;
	['paste']              = 0x07D;
	['find']               = 0x07E;
	['mute']               = 0x07F;
	['volumeup']           = 0x080;
	['volumedown']         = 0x081;
	['kp_comma']           = 0x085;
	['kp_equalsas400']     = 0x086;
	['international1']     = 0x087;
	['international2']     = 0x088;
	['international3']     = 0x089;
	['international4']     = 0x08A;
	['international5']     = 0x08B;
	['international6']     = 0x08C;
	['international7']     = 0x08D;
	['international8']     = 0x08E;
	['international9']     = 0x08F;
	['lang1']              = 0x090;
	['lang2']              = 0x091;
	['lang3']              = 0x092;
	['lang4']              = 0x093;
	['lang5']              = 0x094;
	['lang6']              = 0x095;
	['lang7']              = 0x096;
	['lang8']              = 0x097;
	['lang9']              = 0x098;
	['alterase']           = 0x099;
	['sysreq']             = 0x09A;
	['cancel']             = 0x09B;
	['clear']              = 0x09C;
	['prior']              = 0x09D;
	['return2']            = 0x09E;
	['separator']          = 0x09F;
	['out']                = 0x0A0;
	['oper']               = 0x0A1;
	['clearagain']         = 0x0A2;
	['crsel']              = 0x0A3;
	['exsel']              = 0x0A4;
	['kp_00']              = 0x0B0;
	['kp_000']             = 0x0B1;
	['thousandsseparator'] = 0x0B2;
	['decimalseparator']   = 0x0B3;
	['currencyunit']       = 0x0B4;
	['currencysubunit']    = 0x0B5;
	['kp_leftparen']       = 0x0B6;
	['kp_rightparen']      = 0x0B7;
	['kp_leftbrace']       = 0x0B8;
	['kp_rightbrace']      = 0x0B9;
	['kp_tab']             = 0x0BA;
	['kp_backspace']       = 0x0BB;
	['kp_a']               = 0x0BC;
	['kp_b']               = 0x0BD;
	['kp_c']               = 0x0BE;
	['kp_d']               = 0x0BF;
	['kp_e']               = 0x0C0;
	['kp_f']               = 0x0C1;
	['kp_xor']             = 0x0C2;
	['kp_power']           = 0x0C3;
	['kp_percent']         = 0x0C4;
	['kp_less']            = 0x0C5;
	['kp_greater']         = 0x0C6;
	['kp_ampersand']       = 0x0C7;
	['kp_dblampersand']    = 0x0C8;
	['kp_verticalbar']     = 0x0C9;
	['kp_dblverticalbar']  = 0x0CA;
	['kp_colon']           = 0x0CB;
	['kp_hash']            = 0x0CC;
	['kp_space']           = 0x0CD;
	['kp_at']              = 0x0CE;
	['kp_exclam']          = 0x0CF;
	['kp_memstore']        = 0x0D0;
	['kp_memrecall']       = 0x0D1;
	['kp_memclear']        = 0x0D2;
	['kp_memadd']          = 0x0D3;
	['kp_memsubtract']     = 0x0D4;
	['kp_memmultiply']     = 0x0D5;
	['kp_memdivide']       = 0x0D6;
	['kp_plusminus']       = 0x0D7;
	['kp_clear']           = 0x0D8;
	['kp_clearentry']      = 0x0D9;
	['kp_binary']          = 0x0DA;
	['kp_octal']           = 0x0DB;
	['kp_decimal']         = 0x0DC;
	['kp_hexadecimal']     = 0x0DD;
	['lctrl']              = 0x0E0;
	['lshift']             = 0x0E1;
	['lalt']               = 0x0E2;
	['lgui']               = 0x0E3;
	['rctrl']              = 0x0E4;
	['rshift']             = 0x0E5;
	['ralt']               = 0x0E6;
	['rgui']               = 0x0E7;
	['mode']               = 0x101;
	['audionext']          = 0x102;
	['audioprev']          = 0x103;
	['audiostop']          = 0x104;
	['audioplay']          = 0x105;
	['audiomute']          = 0x106;
	['mediaselect']        = 0x107;
	['www']                = 0x108;
	['mail']               = 0x109;
	['calculator']         = 0x10A;
	['computer']           = 0x10B;
	['ac_search']          = 0x10C;
	['ac_home']            = 0x10D;
	['ac_back']            = 0x10E;
	['ac_forward']         = 0x10F;
	['ac_stop']            = 0x110;
	['ac_refresh']         = 0x111;
	['ac_bookmarks']       = 0x112;
	['brightnessdown']     = 0x113;
	['brightnessup']       = 0x114;
	['displayswitch']      = 0x115;
	['kbdillumtoggle']     = 0x116;
	['kbdillumdown']       = 0x117;
	['kbdillumup']         = 0x118;
	['eject']              = 0x119;
	['sleep']              = 0x11A;
	['app1']               = 0x11B;
	['app2']               = 0x11C;
}


--------------------------------------------------------------------
KeyMaps.SDL2 = {
	['unknown']            = 0x000;
	['a']                  = 0x061;
	['b']                  = 0x062;
	['c']                  = 0x063;
	['d']                  = 0x064;
	['e']                  = 0x065;
	['f']                  = 0x066;
	['g']                  = 0x067;
	['h']                  = 0x068;
	['i']                  = 0x069;
	['j']                  = 0x06A;
	['k']                  = 0x06B;
	['l']                  = 0x06C;
	['m']                  = 0x06D;
	['n']                  = 0x06E;
	['o']                  = 0x06F;
	['p']                  = 0x070;
	['q']                  = 0x071;
	['r']                  = 0x072;
	['s']                  = 0x073;
	['t']                  = 0x074;
	['u']                  = 0x075;
	['v']                  = 0x076;
	['w']                  = 0x077;
	['x']                  = 0x078;
	['y']                  = 0x079;
	['z']                  = 0x07A;
	['1']                  = 0x031;
	['2']                  = 0x032;
	['3']                  = 0x033;
	['4']                  = 0x034;
	['5']                  = 0x035;
	['6']                  = 0x036;
	['7']                  = 0x037;
	['8']                  = 0x038;
	['9']                  = 0x039;
	['0']                  = 0x030;
	['return']             = 0x10D;
	['escape']             = 0x11B;
	['backspace']          = 0x02A;
	['tab']                = 0x02B;
	['space']              = 0x020;
	['-']                  = 0x02D;
	['=']                  = 0x02E;
	['{']                  = 0x02F;
	['}']                  = 0x030;
	['\\']                 = 0x031;
	['nonuslash']          = 0x032;
	[';']                  = 0x033;
	['\'']                 = 0x034;
	['`']                  = 0x035;
	[',']                  = 0x036;
	['.']                  = 0x037;
	['/']                  = 0x038;
	['capslock']           = 0x039;
	['f1']                 = 0x03A;
	['f2']                 = 0x03B;
	['f3']                 = 0x03C;
	['f4']                 = 0x03D;
	['f5']                 = 0x03E;
	['f6']                 = 0x03F;
	['f7']                 = 0x040;
	['f8']                 = 0x041;
	['f9']                 = 0x042;
	['f10']                = 0x043;
	['f11']                = 0x044;
	['f12']                = 0x045;
	['printscreen']        = 0x046;
	['scrolllock']         = 0x047;
	['pause']              = 0x048;
	['insert']             = 0x049;
	['home']               = 0x04A;
	['pageup']             = 0x04B;
	['delete']             = 0x04C;
	['end']                = 0x04D;
	['pagedown']           = 0x04E;
	['right']              = 0x127;
	['left']               = 0x125;
	['down']               = 0x128;
	['up']                 = 0x126;
	['numlockclear']       = 0x053;
	['kp_divide']          = 0x054;
	['kp_multiply']        = 0x055;
	['kp_minus']           = 0x056;
	['kp_plus']            = 0x057;
	['kp_enter']           = 0x058;
	['kp_1']               = 0x059;
	['kp_2']               = 0x05A;
	['kp_3']               = 0x05B;
	['kp_4']               = 0x05C;
	['kp_5']               = 0x05D;
	['kp_6']               = 0x05E;
	['kp_7']               = 0x05F;
	['kp_8']               = 0x060;
	['kp_9']               = 0x061;
	['kp_0']               = 0x062;
	['kp_period']          = 0x063;
	['nonusbackslash']     = 0x064;
	['application']        = 0x065;
	['power']              = 0x066;
	['kp_equals']          = 0x067;
	['f13']                = 0x068;
	['f14']                = 0x069;
	['f15']                = 0x06A;
	['f16']                = 0x06B;
	['f17']                = 0x06C;
	['f18']                = 0x06D;
	['f19']                = 0x06E;
	['f20']                = 0x06F;
	['f21']                = 0x070;
	['f22']                = 0x071;
	['f23']                = 0x072;
	['f24']                = 0x073;
	['execute']            = 0x074;
	['help']               = 0x075;
	['menu']               = 0x076;
	['select']             = 0x077;
	['stop']               = 0x078;
	['again']              = 0x079;
	['undo']               = 0x07A;
	['cut']                = 0x07B;
	['copy']               = 0x07C;
	['paste']              = 0x07D;
	['find']               = 0x07E;
	['mute']               = 0x07F;
	['volumeup']           = 0x080;
	['volumedown']         = 0x081;
	['kp_comma']           = 0x085;
	['kp_equalsas400']     = 0x086;
	['international1']     = 0x087;
	['international2']     = 0x088;
	['international3']     = 0x089;
	['international4']     = 0x08A;
	['international5']     = 0x08B;
	['international6']     = 0x08C;
	['international7']     = 0x08D;
	['international8']     = 0x08E;
	['international9']     = 0x08F;
	['lang1']              = 0x090;
	['lang2']              = 0x091;
	['lang3']              = 0x092;
	['lang4']              = 0x093;
	['lang5']              = 0x094;
	['lang6']              = 0x095;
	['lang7']              = 0x096;
	['lang8']              = 0x097;
	['lang9']              = 0x098;
	['alterase']           = 0x099;
	['sysreq']             = 0x09A;
	['cancel']             = 0x09B;
	['clear']              = 0x09C;
	['prior']              = 0x09D;
	['return2']            = 0x09E;
	['separator']          = 0x09F;
	['out']                = 0x0A0;
	['oper']               = 0x0A1;
	['clearagain']         = 0x0A2;
	['crsel']              = 0x0A3;
	['exsel']              = 0x0A4;
	['kp_00']              = 0x0B0;
	['kp_000']             = 0x0B1;
	['thousandsseparator'] = 0x0B2;
	['decimalseparator']   = 0x0B3;
	['currencyunit']       = 0x0B4;
	['currencysubunit']    = 0x0B5;
	['kp_leftparen']       = 0x0B6;
	['kp_rightparen']      = 0x0B7;
	['kp_leftbrace']       = 0x0B8;
	['kp_rightbrace']      = 0x0B9;
	['kp_tab']             = 0x0BA;
	['kp_backspace']       = 0x0BB;
	['kp_a']               = 0x0BC;
	['kp_b']               = 0x0BD;
	['kp_c']               = 0x0BE;
	['kp_d']               = 0x0BF;
	['kp_e']               = 0x0C0;
	['kp_f']               = 0x0C1;
	['kp_xor']             = 0x0C2;
	['kp_power']           = 0x0C3;
	['kp_percent']         = 0x0C4;
	['kp_less']            = 0x0C5;
	['kp_greater']         = 0x0C6;
	['kp_ampersand']       = 0x0C7;
	['kp_dblampersand']    = 0x0C8;
	['kp_verticalbar']     = 0x0C9;
	['kp_dblverticalbar']  = 0x0CA;
	['kp_colon']           = 0x0CB;
	['kp_hash']            = 0x0CC;
	['kp_space']           = 0x0CD;
	['kp_at']              = 0x0CE;
	['kp_exclam']          = 0x0CF;
	['kp_memstore']        = 0x0D0;
	['kp_memrecall']       = 0x0D1;
	['kp_memclear']        = 0x0D2;
	['kp_memadd']          = 0x0D3;
	['kp_memsubtract']     = 0x0D4;
	['kp_memmultiply']     = 0x0D5;
	['kp_memdivide']       = 0x0D6;
	['kp_plusminus']       = 0x0D7;
	['kp_clear']           = 0x0D8;
	['kp_clearentry']      = 0x0D9;
	['kp_binary']          = 0x0DA;
	['kp_octal']           = 0x0DB;
	['kp_decimal']         = 0x0DC;
	['kp_hexadecimal']     = 0x0DD;
	['lctrl']              = 0x0E0;
	['lshift']             = 0x0E1;
	['lalt']               = 0x0E2;
	['lgui']               = 0x0E3;
	['rctrl']              = 0x0E4;
	['rshift']             = 0x0E5;
	['ralt']               = 0x0E6;
	['rgui']               = 0x0E7;
	['mode']               = 0x101;
	['audionext']          = 0x102;
	['audioprev']          = 0x103;
	['audiostop']          = 0x104;
	['audioplay']          = 0x105;
	['audiomute']          = 0x106;
	['mediaselect']        = 0x107;
	['www']                = 0x108;
	['mail']               = 0x109;
	['calculator']         = 0x10A;
	['computer']           = 0x10B;
	['ac_search']          = 0x10C;
	['ac_home']            = 0x10D;
	['ac_back']            = 0x10E;
	['ac_forward']         = 0x10F;
	['ac_stop']            = 0x110;
	['ac_refresh']         = 0x111;
	['ac_bookmarks']       = 0x112;
	['brightnessdown']     = 0x113;
	['brightnessup']       = 0x114;
	['displayswitch']      = 0x115;
	['kbdillumtoggle']     = 0x116;
	['kbdillumdown']       = 0x117;
	['kbdillumup']         = 0x118;
	['eject']              = 0x119;
	['sleep']              = 0x11A;
	['app1']               = 0x11B;
	['app2']               = 0x11C;
}


--------------------------------------------------------------------
KeyMaps.MOAI = {
	['backspace'] = MOAIKeyCode.BACKSPACE,
	['tab'] = MOAIKeyCode.TAB,
	['return'] = MOAIKeyCode.RETURN,
	['shift'] = MOAIKeyCode.SHIFT,
	['control'] = MOAIKeyCode.CONTROL,
	['alt'] = MOAIKeyCode.ALT,
	['pause'] = MOAIKeyCode.PAUSE,
	['caps_lock'] = MOAIKeyCode.CAPS_LOCK,
	['escape'] = MOAIKeyCode.ESCAPE,
	['space'] = MOAIKeyCode.SPACE,
	['page_up'] = MOAIKeyCode.PAGE_UP,
	['page_down'] = MOAIKeyCode.PAGE_DOWN,
	['end'] = MOAIKeyCode.END,
	['home'] = MOAIKeyCode.HOME,
	['left'] = MOAIKeyCode.LEFT,
	['up'] = MOAIKeyCode.UP,
	['right'] = MOAIKeyCode.RIGHT,
	['down'] = MOAIKeyCode.DOWN,
	['print_screen'] = MOAIKeyCode.PRINT_SCREEN,
	['insert'] = MOAIKeyCode.INSERT,
	['delete'] = MOAIKeyCode.DELETE,
	['0'] = MOAIKeyCode.DIGIT_0,
	['1'] = MOAIKeyCode.DIGIT_1,
	['2'] = MOAIKeyCode.DIGIT_2,
	['3'] = MOAIKeyCode.DIGIT_3,
	['4'] = MOAIKeyCode.DIGIT_4,
	['5'] = MOAIKeyCode.DIGIT_5,
	['6'] = MOAIKeyCode.DIGIT_6,
	['7'] = MOAIKeyCode.DIGIT_7,
	['8'] = MOAIKeyCode.DIGIT_8,
	['9'] = MOAIKeyCode.DIGIT_9,
	['a'] = MOAIKeyCode.A,
	['b'] = MOAIKeyCode.B,
	['c'] = MOAIKeyCode.C,
	['d'] = MOAIKeyCode.D,
	['e'] = MOAIKeyCode.E,
	['f'] = MOAIKeyCode.F,
	['g'] = MOAIKeyCode.G,
	['h'] = MOAIKeyCode.H,
	['i'] = MOAIKeyCode.I,
	['j'] = MOAIKeyCode.J,
	['k'] = MOAIKeyCode.K,
	['l'] = MOAIKeyCode.L,
	['m'] = MOAIKeyCode.M,
	['n'] = MOAIKeyCode.N,
	['o'] = MOAIKeyCode.O,
	['p'] = MOAIKeyCode.P,
	['q'] = MOAIKeyCode.Q,
	['r'] = MOAIKeyCode.R,
	['s'] = MOAIKeyCode.S,
	['t'] = MOAIKeyCode.T,
	['u'] = MOAIKeyCode.U,
	['v'] = MOAIKeyCode.V,
	['w'] = MOAIKeyCode.W,
	['x'] = MOAIKeyCode.X,
	['y'] = MOAIKeyCode.Y,
	['z'] = MOAIKeyCode.Z,
	['gui'] = MOAIKeyCode.GUI,
	['application'] = MOAIKeyCode.APPLICATION,
	['num_0'] = MOAIKeyCode.NUM_0,
	['num_1'] = MOAIKeyCode.NUM_1,
	['num_2'] = MOAIKeyCode.NUM_2,
	['num_3'] = MOAIKeyCode.NUM_3,
	['num_4'] = MOAIKeyCode.NUM_4,
	['num_5'] = MOAIKeyCode.NUM_5,
	['num_6'] = MOAIKeyCode.NUM_6,
	['num_7'] = MOAIKeyCode.NUM_7,
	['num_8'] = MOAIKeyCode.NUM_8,
	['num_9'] = MOAIKeyCode.NUM_9,
	['num_multiply'] = MOAIKeyCode.NUM_MULTIPLY,
	['num_plus'] = MOAIKeyCode.NUM_PLUS,
	['num_minus'] = MOAIKeyCode.NUM_MINUS,
	['num_decimal'] = MOAIKeyCode.NUM_DECIMAL,
	['num_divide'] = MOAIKeyCode.NUM_DIVIDE,
	['f1'] = MOAIKeyCode.F1,
	['f2'] = MOAIKeyCode.F2,
	['f3'] = MOAIKeyCode.F3,
	['f4'] = MOAIKeyCode.F4,
	['f5'] = MOAIKeyCode.F5,
	['f6'] = MOAIKeyCode.F6,
	['f7'] = MOAIKeyCode.F7,
	['f8'] = MOAIKeyCode.F8,
	['f9'] = MOAIKeyCode.F9,
	['f10'] = MOAIKeyCode.F10,
	['f11'] = MOAIKeyCode.F11,
	['f12'] = MOAIKeyCode.F12,
	['num_lock'] = MOAIKeyCode.NUM_LOCK,
	['scroll_lock'] = MOAIKeyCode.SCROLL_LOCK,
	['oem_1'] = MOAIKeyCode.OEM_1,
	['oem_plus'] = MOAIKeyCode.OEM_PLUS,
	['oem_comma'] = MOAIKeyCode.OEM_COMMA,
	['oem_minus'] = MOAIKeyCode.OEM_MINUS,
	['oem_period'] = MOAIKeyCode.OEM_PERIOD,
	['oem_2'] = MOAIKeyCode.OEM_2,
	['oem_3'] = MOAIKeyCode.OEM_3,
	['oem_4'] = MOAIKeyCode.OEM_4,
	['oem_5'] = MOAIKeyCode.OEM_5,
	['oem_6'] = MOAIKeyCode.OEM_6,
	['oem_7'] = MOAIKeyCode.OEM_7,
	['oem_8'] = MOAIKeyCode.OEM_8,
	['oem_102'] = MOAIKeyCode.OEM_102
}

--------------------------------------------------------------------
KeyMaps.OSX = {
	['unknown']            = 0x000;
	['a']                  = 0x061;
	['b']                  = 0x062;
	['c']                  = 0x063;
	['d']                  = 0x064;
	['e']                  = 0x065;
	['f']                  = 0x066;
	['g']                  = 0x067;
	['h']                  = 0x068;
	['i']                  = 0x069;
	['j']                  = 0x06A;
	['k']                  = 0x06B;
	['l']                  = 0x06C;
	['m']                  = 0x06D;
	['n']                  = 0x06E;
	['o']                  = 0x06F;
	['p']                  = 0x070;
	['q']                  = 0x071;
	['r']                  = 0x072;
	['s']                  = 0x073;
	['t']                  = 0x074;
	['u']                  = 0x075;
	['v']                  = 0x076;
	['w']                  = 0x077;
	['x']                  = 0x078;
	['y']                  = 0x079;
	['z']                  = 0x07A;
	['1']                  = 0x031;
	['2']                  = 0x032;
	['3']                  = 0x033;
	['4']                  = 0x034;
	['5']                  = 0x035;
	['6']                  = 0x036;
	['7']                  = 0x037;
	['8']                  = 0x038;
	['9']                  = 0x039;
	['0']                  = 0x03A;
	['return']             = 0x10D;
	['escape']             = 0x11B;
	['backspace']          = 0x02A;
	['tab']                = 0x02B;
	['space']              = 0x020;
	-- ['-']                  = 0x02D;
	-- ['=']                  = 0x02E;
	-- ['{']                  = 0x02F;
	-- ['}']                  = 0x030;
	-- ['\\']                 = 0x031;
	-- ['nonuslash']          = 0x032;
	-- [';']                  = 0x033;
	-- ['\'']                 = 0x034;
	-- ['`']                  = 0x035;
	-- [',']                  = 0x036;
	-- ['.']                  = 0x037;
	-- ['/']                  = 0x038;
	-- ['capslock']           = 0x039;
	['f1']                 = 0x170;
	['f2']                 = 0x171;
	['f3']                 = 0x172;
	['f4']                 = 0x173;
	['f5']                 = 0x174;
	['f6']                 = 0x175;
	['f7']                 = 0x176;
	['f8']                 = 0x177;
	['f9']                 = 0x178;
	['f10']                = 0x179;
	['f11']                = 0x17A;
	['f12']                = 0x17B;
	-- ['printscreen']        = 0x046;
	-- ['scrolllock']         = 0x047;
	-- ['pause']              = 0x048;
	-- ['insert']             = 0x049;
	-- ['home']               = 0x04A;
	-- ['pageup']             = 0x04B;
	-- ['delete']             = 0x04C;
	-- ['end']                = 0x04D;
	-- ['pagedown']           = 0x04E;
	['right']              = 0x127;
	['left']               = 0x125;
	['down']               = 0x128;
	['up']                 = 0x126;
	-- ['numlockclear']       = 0x053;
	-- ['kp_divide']          = 0x054;
	-- ['kp_multiply']        = 0x055;
	-- ['kp_minus']           = 0x056;
	-- ['kp_plus']            = 0x057;
	-- ['kp_enter']           = 0x058;
	-- ['kp_1']               = 0x059;
	-- ['kp_2']               = 0x05A;
	-- ['kp_3']               = 0x05B;
	-- ['kp_4']               = 0x05C;
	-- ['kp_5']               = 0x05D;
	-- ['kp_6']               = 0x05E;
	-- ['kp_7']               = 0x05F;
	-- ['kp_8']               = 0x060;
	-- ['kp_9']               = 0x061;
	-- ['kp_0']               = 0x062;
	-- ['kp_period']          = 0x063;
	-- ['nonusbackslash']     = 0x064;
	-- ['application']        = 0x065;
	-- ['power']              = 0x066;
	-- ['kp_equals']          = 0x067;
	-- ['f13']                = 0x068;
	-- ['f14']                = 0x069;
	-- ['f15']                = 0x06A;
	-- ['f16']                = 0x06B;
	-- ['f17']                = 0x06C;
	-- ['f18']                = 0x06D;
	-- ['f19']                = 0x06E;
	-- ['f20']                = 0x06F;
	-- ['f21']                = 0x070;
	-- ['f22']                = 0x071;
	-- ['f23']                = 0x072;
	-- ['f24']                = 0x073;
	-- ['execute']            = 0x074;
	-- ['help']               = 0x075;
	-- ['menu']               = 0x076;
	-- ['select']             = 0x077;
	-- ['stop']               = 0x078;
	-- ['again']              = 0x079;
	-- ['undo']               = 0x07A;
	-- ['cut']                = 0x07B;
	-- ['copy']               = 0x07C;
	-- ['paste']              = 0x07D;
	-- ['find']               = 0x07E;
	-- ['mute']               = 0x07F;
	-- ['volumeup']           = 0x080;
	-- ['volumedown']         = 0x081;
	-- ['kp_comma']           = 0x085;
	-- ['kp_equalsas400']     = 0x086;
	-- ['international1']     = 0x087;
	-- ['international2']     = 0x088;
	-- ['international3']     = 0x089;
	-- ['international4']     = 0x08A;
	-- ['international5']     = 0x08B;
	-- ['international6']     = 0x08C;
	-- ['international7']     = 0x08D;
	-- ['international8']     = 0x08E;
	-- ['international9']     = 0x08F;
	-- ['lang1']              = 0x090;
	-- ['lang2']              = 0x091;
	-- ['lang3']              = 0x092;
	-- ['lang4']              = 0x093;
	-- ['lang5']              = 0x094;
	-- ['lang6']              = 0x095;
	-- ['lang7']              = 0x096;
	-- ['lang8']              = 0x097;
	-- ['lang9']              = 0x098;
	-- ['alterase']           = 0x099;
	-- ['sysreq']             = 0x09A;
	-- ['cancel']             = 0x09B;
	-- ['clear']              = 0x09C;
	-- ['prior']              = 0x09D;
	-- ['return2']            = 0x09E;
	-- ['separator']          = 0x09F;
	-- ['out']                = 0x0A0;
	-- ['oper']               = 0x0A1;
	-- ['clearagain']         = 0x0A2;
	-- ['crsel']              = 0x0A3;
	-- ['exsel']              = 0x0A4;
	-- ['kp_00']              = 0x0B0;
	-- ['kp_000']             = 0x0B1;
	-- ['thousandsseparator'] = 0x0B2;
	-- ['decimalseparator']   = 0x0B3;
	-- ['currencyunit']       = 0x0B4;
	-- ['currencysubunit']    = 0x0B5;
	-- ['kp_leftparen']       = 0x0B6;
	-- ['kp_rightparen']      = 0x0B7;
	-- ['kp_leftbrace']       = 0x0B8;
	-- ['kp_rightbrace']      = 0x0B9;
	-- ['kp_tab']             = 0x0BA;
	-- ['kp_backspace']       = 0x0BB;
	-- ['kp_a']               = 0x0BC;
	-- ['kp_b']               = 0x0BD;
	-- ['kp_c']               = 0x0BE;
	-- ['kp_d']               = 0x0BF;
	-- ['kp_e']               = 0x0C0;
	-- ['kp_f']               = 0x0C1;
	-- ['kp_xor']             = 0x0C2;
	-- ['kp_power']           = 0x0C3;
	-- ['kp_percent']         = 0x0C4;
	-- ['kp_less']            = 0x0C5;
	-- ['kp_greater']         = 0x0C6;
	-- ['kp_ampersand']       = 0x0C7;
	-- ['kp_dblampersand']    = 0x0C8;
	-- ['kp_verticalbar']     = 0x0C9;
	-- ['kp_dblverticalbar']  = 0x0CA;
	-- ['kp_colon']           = 0x0CB;
	-- ['kp_hash']            = 0x0CC;
	-- ['kp_space']           = 0x0CD;
	-- ['kp_at']              = 0x0CE;
	-- ['kp_exclam']          = 0x0CF;
	-- ['kp_memstore']        = 0x0D0;
	-- ['kp_memrecall']       = 0x0D1;
	-- ['kp_memclear']        = 0x0D2;
	-- ['kp_memadd']          = 0x0D3;
	-- ['kp_memsubtract']     = 0x0D4;
	-- ['kp_memmultiply']     = 0x0D5;
	-- ['kp_memdivide']       = 0x0D6;
	-- ['kp_plusminus']       = 0x0D7;
	-- ['kp_clear']           = 0x0D8;
	-- ['kp_clearentry']      = 0x0D9;
	-- ['kp_binary']          = 0x0DA;
	-- ['kp_octal']           = 0x0DB;
	-- ['kp_decimal']         = 0x0DC;
	-- ['kp_hexadecimal']     = 0x0DD;
	['lctrl']              = 0x0E0;
	['lshift']             = 0x0E1;
	['lalt']               = 0x0E2;
	['lgui']               = 0x0E3;
	['rctrl']              = 0x0E4;
	['rshift']             = 0x0E5;
	['ralt']               = 0x0E6;
	['rgui']               = 0x0E7;
	-- ['mode']               = 0x101;
	-- ['audionext']          = 0x102;
	-- ['audioprev']          = 0x103;
	-- ['audiostop']          = 0x104;
	-- ['audioplay']          = 0x105;
	-- ['audiomute']          = 0x106;
	-- ['mediaselect']        = 0x107;
}


--------------------------------------------------------------------
KeyMaps.GLUT = {
	-- ['f1']=	1 ;
	-- ['f2']=	2 ;
	-- ['f3']=	3 ;
	-- ['f4']=	4 ;
	-- ['f5']=	5 ;
	-- ['f6']=	6 ;
	-- ['f7']=	7 ;
	['backspace']=	8 ;
	['delete']=	127 ;
	['tab']=	9 ;
	-- ['f10']=	10 ;
	-- ['f11']=	11 ;
	-- ['f12']=	12 ;
	['escape']=	27 ;
	['space']=	32 ;
	['enter']=	13 ;
	--directional key
	['left']=	80 ;
	['up']=	82 ;
	['right']=	79 ;
	['down']=	81 ;
	-- ['pageup']=104 ;
	-- ['pagedown']=105 ;
	-- ['home']=	106 ;
	-- ['end']=	107 ;
	-- ['insert']=	108 ;
	['lctrl']  = 224;
	['lshift'] = 225;
	['lalt']   = 226;
	['lcmd']   = 227;

}


--------------------------------------------------------------------
KeyMaps.HTML5 = {
	enter = 13,
	space = 32,
	lshift = 16,
	down = 81,
	lctrl = 224,
	backspace = 8,
	left = 80,
	delete = 127,
	["-"] = 173,
	up = 38,
	lalt = 18,
	escape = 27,
	lcmd = 227,
	tab = 9,
	right = 37
}


--TODO: fix this
for i = 39, 64 do
	KeyMaps.GLUT[ string.char ( i ) ] = i
	KeyMaps.HTML5[ string.char ( i ) ] = i
end

for i = 91, 122 do
	KeyMaps.GLUT[ string.char ( i ) ] = i
	KeyMaps.HTML5[ string.char ( i ) ] = i
end


--------------------------------------------------------------------
KeyMaps.SDL_OSX = table.simplecopy ( KeyMaps.SDL )
KeyMaps.SDL_OSX[ 'lctrl' ] = KeyMaps.SDL[ 'lgui' ]
KeyMaps.SDL_OSX[ 'lmeta' ] = KeyMaps.SDL[ 'lctrl' ]
KeyMaps.SDL_OSX[ 'rctrl' ] = KeyMaps.SDL[ 'rgui' ]
KeyMaps.SDL_OSX[ 'rmeta' ] = KeyMaps.SDL[ 'rctrl' ]
KeyMaps.SDL_OSX[ 'lgui' ] = nil
KeyMaps.SDL_OSX[ 'rgui' ] = nil


--------------------------------------------------------------------
local function getKeyMap ()
	local osBrand = MOAIEnvironment.osBrand
	local configuration = MOAIInputMgr.configuration or 'SDL'

	_info ( 'using input configuration:', configuration )

	if configuration == 'CandyEditor' then
		return KeyMaps.CandyEditor

	elseif configuration == 'SDL' then
		if osBrand == 'OSX' then
			return KeyMaps.SDL_OSX
		else
			return KeyMaps.SDL2
		end
	elseif configuration == "NX" then
		return KeyMaps.NX
	else
		return KeyMaps.GLUT
	end
end

local modifierKeyMap = {
	lmeta = true,
	lctrl = true,
	ralt = true,
	lshift = true,
	rgui = true,
	rctrl = true,
	rshift = true,
	rmeta = true,
	lgui = true,
	lalt = true
}

function isModifierKey ( keyName )
	return keyName and modifierKeyMap[ keyName ] or false
end

KeyMapModule.KeyMaps = KeyMaps
KeyMapModule.getKeyMap = getKeyMap
KeyMapModule.isModifierKey = isModifierKey

return KeyMapModule