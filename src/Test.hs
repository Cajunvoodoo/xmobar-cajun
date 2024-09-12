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

diskIOS p = DiskIO [("/", "<read> <write>")] (diskArgs p) 10

cpuFreq' p = CpuFreq (p <~> args) 50
 where
  args = ["-t", "<avg>", "-L", "1", "-H", "2", "-d", "2"]

memory' = Memory args 20
 where
  template = "<used> <available>"
  args = ["-t", template, "-p", "2", "-d", "1", "--", "--scale", "1024"]

config p =
  (baseConfig p)
    { position = TopSize C 100 24
    , bgColor = if pIsLight p then "#f0f0f0" else "black"
    , alpha = 255 -- 233
    , border = FullB
    , textOffsets = []
    , textOffset = 0
    , iconOffset = 0
    , iconRoot = "/home/jao/tmp"
    , -- , font = "Source Code Pro, Noto Color Emoji Regular 9, Italic 9"
      font = "DejaVu Sans Mono, Noto Color Emoji 9, Regular 9"
    , commands =
        [ Run (topProcL p isXmonad)
        , Run (load p)
        , Run (iconBatt p)
        , Run (cpuBars p)
        , Run memory'
        , Run (diskU p)
        , Run (diskIOS p)
        , Run (kbd p)
        , Run (coreTemp p)
        , Run (wireless p "wlan0")
        , Run (dynNetwork p)
        , Run (vpnMark "wg-mullvad")
        , Run tun0
        , Run (masterVol p)
        , Run captureVol
        , Run laTime
        , Run localTime
        , Run (cpuFreq' p)
        , Run (weather "EGPH" p)
        , Run nmmail
        ]
          ++ extraCmds
    , template = "{something in the middle}"
    -- , template = trayT
    --            ++ " |batt0| "
    --            ++ "<action=`toggle-app.sh nm-applet`>"
    --            -- ++ "  <fc=#000000,#ffec8b55:1>|wg-mullvad||tun0||wlan0wi|</fc>"
    --            ++ "  <fc=#000000>|wg-mullvad||tun0||wlan0wi|</fc>"
    --            ++ "</action>"
    --            ++ " |dynnetwork| "
    --            ++ "<action=`toggle-app.sh pasystray`>"
    --            ++ "  |default:Master| " ++ dimi "\xf130" ++ " |default:Capture|"
    --            ++ "</action>"
    --            ++ "    |EGPH|"
    --            ++ fc "sienna4" " |mail|"
    --            ++ " |kbd|"
    --            ++ "{"
    --            ++ box "color=red width=1 mt=2 mb=2 ml=2 mr=2" ""
    --            -- "something in the middle something in the middle something in the middle something in the middle"
    --            ++ "<fc=red><icon=hbar_1.xbm/></fc>"
    --            ++ "}"
    --            ++ box "type=HBoth" " |multicpu|"
    --            ++ "  |cpufreq|"
    --            ++ box "type=VBoth mt=2 mb=2 color=green" " |multicoretemp|"
    --            ++ box "" " something loooooonger on the right side " -- "  |top| "
    --            ++ dimi "\xf080" ++ " |memory|  "
    --            ++ dimi "\xf0a0" ++ "|diskio| |disku| "
    --            ++ "  |datetime| "
    --            ++ " |laTime| "
    }
 where
  dimi = fc "grey40" . fn 1
  box _ str = str
  -- box args str = "<box " ++ args ++ ">" ++ str ++ "</box>"
  isXmonad = pWm p == Just "xmonad"
  trayT = if isXmonad then "|tray|" else ""
  eLog p = if isXmonad then "|XMonadLog|" else fc (pHigh p) "|elog|"
  extraCmds =
    if isXmonad
      then
        [ Run (NamedXPropertyLog "_XMONAD_TRAYPAD" "tray")
        , Run XMonadLog
        ]
      else [Run (NamedXPropertyLog "_EMACS_LOG" "elog")]

main :: IO ()
main = palette >>= configFromArgs . config >>= xmobar
