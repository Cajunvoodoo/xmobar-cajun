import Config
import Monitors
import Xmobar

topProcL p = TopProc (p <~> args) 15
 where
  template = "<both1>  <both2>  <both3> ·  <mboth1>  <mboth2>  <mboth3>"
  args = ["-t", template, "-w", "12", "-L", "10", "-H", "80"]

diskIOS p = DiskIO [("/", "<read> <write>")] (diskArgs p) 10

cpuFreq' p = CpuFreq (p <~> args) 50
 where
  args = ["-t", "<avg>", "-L", "1", "-H", "2", "-S", "Off", "-d", "2"]

memory' = Memory args 20
 where
  template = "<used> <available>"
  args = ["-t", template, "-p", "2", "-d", "1", "--", "--scale", "1024"]

master p = Volume "default" "Master" (args ++ ("--" : ext)) 10
 where
  args = ["-t", "<status> <volume>"]
  ext = ["-C", pForeground p, "-c", "sienna4", "-O", "🔊", "-o", "🔇"]

capture = Volume "default" "Capture" ["-t", "<volume>"] 10

batt0 p =
  BatteryN
    ["BAT0"]
    [ "-t"
    , "<acstatus>"
    , "-S"
    , "Off"
    , "-d"
    , "0" -- , "-m", "2"
    , "-L"
    , "10"
    , "-H"
    , "90" -- , "-p", "2"
    , "--low"
    , pHigh p
    , "--normal"
    , pNormal p
    , "--high"
    , pLow p
    , "-W"
    , "0"
    , "-f"
    , "\129707\129707\129707🔋🔋🔋🔋🔋🔋🔋✳️"
    , "--"
    , "-P"
    , "-a"
    , "notify-send -u critical 'Battery running out!!!!!!'"
    , "-A"
    , "7"
    , "-i"
    , "＊" -- "✳️"
    , "-o"
    , "\129707 <left> <timeleft> <watts>"
    , "-O"
    , "🔋" ++ " <left> <timeleft> <watts>"
    , -- , "-o", "<leftbar> <left> <timeleft> <watts>"
      -- , "-O", "<leftbar> <left> <timeleft> <watts>"
      "-H"
    , "10"
    , "-L"
    , "7"
    , "-h"
    , pHigh p
    , "-l"
    , pLow p
    ]
    50
    "batt0"

weath st p =
  WeatherX
    st
    [ ("", "🌡")
    , ("clear", "🔆")
    , ("sunny", "🔆")
    , ("fair", "🔆")
    , ("mostly clear", "🌤️")
    , ("mostly sunny", "🌤️")
    , ("partly sunny", "⛅")
    , ("obscured", "🌁")
    , ("fog", "🌫️")
    , ("foggy", "🌫️")
    , ("cloudy", "☁️")
    , ("overcast", "☁️")
    , ("partly cloudy", "⛅")
    , ("mostly cloudy", "☁️")
    , ("considerable cloudiness", "☁️")
    , ("light rain", "🌦️")
    , ("rain", "🌨️")
    , ("ice crystals", "❄️")
    , ("light snow", "🌨️")
    , ("snow", "❄️")
    ]
    ( mkArgs
        p
        [ "-t"
        , "<skyConditionS> <tempC>° <weather> 🌫 <windKmh>"
        , "-L"
        , "10"
        , "-H"
        , "25"
        , "-T"
        , "25"
        , "-E"
        , ".."
        ]
        ["-w", ""]
    )
    18000

config p =
  (baseConfig p)
    { position = TopSize C 100 22
    , textOutput = True
    , font = "Hack 10"
    , commands =
        [ Run (topProcL p)
        , Run (batt0 p)
        , Run (cpu p)
        , Run (cpuFreq' p)
        , Run memory'
        , Run (diskU p)
        , Run (diskIOS p)
        , Run (kbd p)
        , Run (coreTemp p)
        , Run (wireless p "wlan0")
        , Run (dynNetwork p)
        , Run (vpnMark "wg-mullvad")
        , Run tun0
        , Run (master p)
        , Run capture
        , Run laTime
        , Run localTime
        , Run (weath "EGPH" p)
        , Run (NamedXPropertyLog "_EMACS_LOG" "elog")
        ]
    , template =
        " |batt0| "
          ++ " 🖧 |wg-mullvad||tun0||wlan0wi|"
          -- ++ "  |wg-mullvad||tun0||wlan0wi|"
          ++ " |dynnetwork| "
          ++ "  |default:Master| 🎙️ |default:Capture|"
          ++ "  |EGPH|"
          ++ " |elog|"
          ++ "{*}"
          ++ "|kbd|"
          ++ " |cpufreq|"
          ++ " |multicpu|"
          ++ " |multicoretemp|"
          ++ "   |top| "
          ++ " ␞ |memory| "
          ++ " |diskio| 🖴 |disku| "
          ++ "  |datetime| "
          ++ "|laTime| "
    }

main :: IO ()
main = palette >>= configFromArgs . config >>= xmobar
