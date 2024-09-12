import Config
import Monitors
import Xmobar

topProcL p s = TopProc (p <~> args) 15
 where
  temp
    | s = "<both1>  <both2>  <both3> ·  <mboth1>  <mboth2>  <mboth3>"
    | otherwise =
        "<both1>  <both2>  <both3>  <both4> "
          ++ "·  <mboth1>  <mboth2>  <mboth3>  <mboth4>"
  args = ["-t", temp, "-w", "12", "-L", "10", "-H", "80"]

diskIOS p = DiskIO [("/", "<total>"), ("/home", "<total>")] (diskArgs p) 10

diskU' p =
  DiskU
    [("/", "/ <free>"), ("/var", "/v <free>"), ("/home", "/h <free>")]
    (p >~< ["-L", "20", "-H", "70", "-m", "1", "-p", "3"])
    20

cpuFreq' p = CpuFreq (p <~> args) 50
 where
  args = ["-t", "<avg>", "-L", "1", "-H", "2", "-d", "2"]

memory' = Memory args 20
 where
  template = "<used> <available>"
  args = ["-t", template, "-p", "2", "-d", "1", "--", "--scale", "1024"]

config p =
  (baseConfig p)
    { position = TopSize C 100 24 -- TopP 0 276

    -- Position xmobar along the top, with a stalonetray in the top right.
    -- Add right padding to xmobar to ensure stalonetray and xmobar don't
    -- overlap. stalonetrayrc-single is configured for 12 icons, each 23px
    -- wide.
    -- right_padding = num_icons * icon_size
    -- right_padding = 12 * 23 = 276
    -- Example: position = TopP 0 276
    -- , font = "xft:monospace-8"
    , font = "Hack, Noto Color Emoji Regular 9, Light 9"
    , bgColor = "#000000"
    , fgColor = "#ffffff"
    , alpha = 233
    , border = FullB
    , textOffset = 0
    , iconOffset = 0
    , lowerOnStart = False
    , overrideRedirect = True
    , allDesktops = True
    , persistent = False
    , commands = [
        Run $ XPropertyLog "_XMONAD_LOG_1"
      , Run $ Weather "KBOS" ["-t","<tempF>F <skyCondition>","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000
      , Run $ cpuBars p
      , Run $ weather  "KBOS" p
      , Run $ batt p
      -- , Run $ MultiCpu ["-t","Cpu: <total0> <total1> <total2> <total3>","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10
      , Run memory
      , Run swapMem
      -- , Run $ Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10
      -- , Run $ Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10
      -- , Run $ Network "eth0" ["-t","Net: <rx>, <tx>","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10
      , Run $ dynNetwork p
      , Run $ Date "%a %b %_d %k:%M" "date" 10
      -- , Run $ Com "getMasterVolume" [] "volumelevel" 10
      , Run $ masterAlsa p
      , Run StdinReader
    ]
    , sepChar = "%"
    , alignSep = "}{"
    , template = "%_XMONAD_LOG_1% %dynnetwork% }{ %KBOS% %multicpu%  %memory%  %swap%  <fc=#b2b2ff>%default:Master%</fc>   <fc=#FFFFCC>%date%</fc> %batt0%"
    }
    -- { position = TopSize C 100 24
    -- , bgColor = if pIsLight p then "#f0f0f0" else "black"
    -- , alpha = 233
    -- , border = FullB
    -- , textOffset = 0
    -- , iconOffset = 0
    -- , dpi = 0
    -- , -- , font = "Source Code Pro, Noto Color Emoji Regular 9, Regular 9"
    --   -- , font = "DejaVu Sans Mono, Noto Color Emoji 9, Regular 9"
    --   font = "Hack, Noto Color Emoji Regular 9, Light 9"
    -- , commands =
    --     [ Run (topProcL p isXmonad)
    --     , Run (load p)
    --     , Run (iconBatt p)
    --     , --               , Run (cpuBars p)
    --       Run memory'
    --     , Run (diskU' p)
    --     , Run (diskIOS p)
    --     , Run (kbd p)
    --     , Run (coreTemp p)
    --     , Run (wireless p "wlan0")
    --     , Run (dynNetwork p)
    --     , --               , Run (vpnMark "wg-mullvad")
    --       --               , Run tun0
    --       --               , Run (masterVol p)
    --       --               , Run captureVol
    --       Run (masterAlsa p)
    --     , Run captureAlsa
    --     , Run laTime
    --     , Run localTime
    --     , Run (cpuFreq' p)
    --     , Run (weather "KBOS" p)
    --     ]
    --       ++ extraCmds
    -- , template =
    --     trayT
    --       ++ " |batt0| "
    --       ++ "<action=`toggle-app.sh nm-applet`>"
    --       ++ "  <fc=#000000>|wlan0wi|</fc>"
    --       ++ "</action>"
    --       ++ " |dynnetwork| "
    --       ++ "<action=`toggle-app.sh pasystray`>"
    --       --             ++ "  |default:Master| " ++ dimi "\xf130" ++ " |default:Capture|"
    --       ++ "  |alsa:default:Master| "
    --       ++ dimi "\xf130"
    --       ++ " |alsa:default:Capture|"
    --       ++ "</action>"
    --       ++ "    |KBOS|"
    --       ++ mail
    --       ++ " |kbd| "
    --       ++ eLog p
    --       ++ "{"
    --       ++ "}"
    --       --             ++ "|multicpu|"
    --       ++ "  |cpufreq|"
    --       ++ " |multicoretemp|"
    --       ++ "  |top|   "
    --       ++ dimi "\xf080"
    --       ++ " |memory|  "
    --       ++ dimi "\xf0a0"
    --       ++ "|diskio| |disku| "
    --       ++ "  |datetime| "
    --       ++ " |laTime| "
    -- }
 where
  dimi = fc "grey40" . fn 1
  isXmonad = pWm p == Just "xmonad"
  trayT = if isXmonad then "|tray|" else ""
  eLog p = if isXmonad then "|XMonadLog|" else fc (pHigh p) "|elog|"
  mail = if isXmonad then fc "sienna4" " |mail|" else ""
  extraCmds =
    if isXmonad
      then
        [ Run (NamedXPropertyLog "_XMONAD_TRAYPAD" "tray")
        , Run XMonadLog
        , Run nmmail
        ]
      else [Run (NamedXPropertyLog "_EMACS_LOG" "elog")]

main :: IO ()
main = palette >>= configFromArgs . config >>= xmobar
