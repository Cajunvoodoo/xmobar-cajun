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
    { position = TopSize C 100 24
    , bgColor = if pIsLight p then "#f0f0f0" else "black"
    , alpha = 233
    , border = FullB
    , textOffset = 0
    , iconOffset = 0
    , dpi = 0
    , -- , font = "Source Code Pro, Noto Color Emoji Regular 9, Regular 9"
      -- , font = "DejaVu Sans Mono, Noto Color Emoji 9, Regular 9"
      font = "Hack, Noto Color Emoji Regular 9, Light 9"
    , commands =
        [ Run (topProcL p isXmonad)
        , Run (load p)
        , Run (iconBatt p)
        , --               , Run (cpuBars p)
          Run memory'
        , Run (diskU' p)
        , Run (diskIOS p)
        , Run (kbd p)
        , Run (coreTemp p)
        , Run (wireless p "wlan0")
        , Run (dynNetwork p)
        , --               , Run (vpnMark "wg-mullvad")
          --               , Run tun0
          --               , Run (masterVol p)
          --               , Run captureVol
          Run (masterAlsa p)
        , Run captureAlsa
        , Run laTime
        , Run localTime
        , Run (cpuFreq' p)
        , Run (weather "EGPH" p)
        ]
          ++ extraCmds
    , template =
        trayT
          ++ " |batt0| "
          ++ "<action=`toggle-app.sh nm-applet`>"
          ++ "  <fc=#000000>|wlan0wi|</fc>"
          ++ "</action>"
          ++ " |dynnetwork| "
          ++ "<action=`toggle-app.sh pasystray`>"
          --             ++ "  |default:Master| " ++ dimi "\xf130" ++ " |default:Capture|"
          ++ "  |alsa:default:Master| "
          ++ dimi "\xf130"
          ++ " |alsa:default:Capture|"
          ++ "</action>"
          ++ "    |EGPH|"
          ++ mail
          ++ " |kbd| "
          ++ eLog p
          ++ "{"
          ++ "}"
          --             ++ "|multicpu|"
          ++ "  |cpufreq|"
          ++ " |multicoretemp|"
          ++ "  |top|   "
          ++ dimi "\xf080"
          ++ " |memory|  "
          ++ dimi "\xf0a0"
          ++ "|diskio| |disku| "
          ++ "  |datetime| "
          ++ " |laTime| "
    }
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
