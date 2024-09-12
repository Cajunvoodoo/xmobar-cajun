import Config
import Monitors
import Xmobar

memoratio = Memory ["-t", "<usedratio>%", "-p", "2", "-W", "3"] 20

topProcL p = TopProc (p <~> args) 15
 where
  template =
    "<both1>  <both2>  <both3>  <both4> "
      ++ "·  <mboth1>  <mboth2>  <mboth3>  <mboth4>"
  args = ["-t", template, "-w", "12", "-L", "10", "-H", "80"]

diskIOS p = DiskIO [("/", "<total>"), ("/home", "<total>")] (diskArgs p) 10

-- mpd a p i = MPDX [ "-W", "12", "-t", "<statei> <remaining>"
--                  , "--", "-p", p, "-P", "\xf144", "-Z", fni i, "-S", fni i] 20 a

-- mpdMon = mpd "mpd" "6600" "🎶"

mprisx client width =
  Mpris2
    client
    [ "-t"
    , " <title> "
    , "-T"
    , show width
    , "-E"
    , "…"
    , "-M"
    , "100"
    , "-x"
    , ""
    ]
    40

config p =
  (baseConfig p)
    { position = TopSize C 100 (defaultHeight - 1)
    , textOutput = True
    , textOutputFormat = Swaybar
    , font = "Source Code Pro Medium 9"
    , bgColor = "#ffffffc0"
    , fgColor = "#000000"
    , border = FullB
    , commands =
        [ Run (topProcL p)
        , Run (iconBatt p)
        , -- , Run mpdMon
          Run (cpu p)
        , Run memoratio
        , Run (diskU p)
        , Run (diskIOS p)
        , Run brightness
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
        , Run w -- LEGE, LEBL, KCV0
        , Run (PipeReader ":/tmp/emacs.status" "estat")
        , Run nmmail
        ]
    , template =
        fc "#a0522d" "|mail| |estat|  "
          ++ " |batt0| "
          ++ "   "
          ++ "<action=`toggle-app.sh nm-applet --indicator`>"
          ++ " |wg-mullvad||tun0||wlan0wi|"
          ++ "</action>"
          ++ " |dynnetwork| "
          ++ "<hspace=3/>"
          ++ "<action=`toggle-app.sh pavucontrol`>"
          ++ "  |default:Master| "
          ++ fn 7 "\xf130"
          ++ " |default:Capture|"
          ++ "</action>  "
          -- ++  "|mpd|"
          ++ "<hspace=3/>"
          ++ "   |EGPH| "
          ++ " {} <hspace=3/>"
          ++ "|multicpu| "
          ++ "|multicoretemp| "
          ++ " |top|   "
          ++ "<hspace=1/>"
          ++ fni "☸"
          ++ " |memory| "
          ++ " |diskio| |disku| "
          ++ "<hspace=3/>"
          ++ " |datetime| "
          ++ " |laTime|  "
    }
 where
  dimi = fc (pDim p)
  w = weather' "<skyConditionS> <tempC>° <weather>" "EGPH" p

main :: IO ()
main = palette >>= configFromArgs . config >>= xmobar
