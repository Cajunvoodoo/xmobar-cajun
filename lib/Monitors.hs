module Monitors where

import Config
import Control.Concurrent
import Control.Concurrent.Async (async)
import Control.Concurrent.STM
import qualified Data.Char as Char
import qualified Text.Printf as Printf
import Xmobar

topProc p =
  TopProc
    ( p
        <~> [ "-t"
            , "<mboth3>  <mboth2>  <mboth1> \
              \· <both3>  <both2>  <both1>"
            , "-w"
            , "10"
            , "-L"
            , "10"
            , "-H"
            , "80"
            ]
    )
    15

topProc' p =
  TopProc
    ( p
        <~> [ "-t"
            , "<mboth1>  <mboth2>  <mboth3> \
              \· <both1>  <both2>  <both3>"
            , "-w"
            , "10"
            , "-L"
            , "10"
            , "-H"
            , "80"
            ]
    )
    15

wireless p n =
  Wireless
    n
    ( p
        >~< [ "-t"
            , "<essid>"
            , -- fc (pLow p) (fni "\xf1eb " ++ "<essid>")
              -- <quality>\xf09e
              "-W"
            , "5"
            , "-M"
            , "15"
            , "-m"
            , "3"
            , "-L"
            , "20"
            , "-H"
            , "80"
            ]
    )
    20
wirelessx p n =
  Wireless
    n
    ( p
        >~< [ "-t"
            , "<essid>"
                ++ fn 1 "↑ "
                ++ "<tx>  "
                ++ fn 1 "↓"
                ++ " <rx>"
            , -- fc (pLow p) (fni "\xf1eb " ++ "<essid>")
              -- <quality>\xf09e
              "-W"
            , "5"
            , "-M"
            , "15"
            , "-m"
            , "3"
            , "-L"
            , "20"
            , "-H"
            , "80"
            ]
    )
    20

cpu p =
  MultiCpu
    ( p
        <~> [ "-t"
            , "<total>"
            , "-S"
            , "on"
            , "-c"
            , " "
            , "-L"
            , "30"
            , "-H"
            , "70"
            , "-p"
            , "3"
            , "-a"
            , "l"
            ]
    )
    10

multiCPU p =
  MultiCpu
    ( p
        <~> [ "-t"
            , "<autototal>"
            , "-S"
            , "on"
            , "-b"
            , " "
            , "-f"
            , "*"
            , "-c"
            , " "
            , "-L"
            , "30"
            , "-H"
            , "70"
            , "-p"
            , "3"
            , "-a"
            , "l"
            ]
    )
    10

cpuBars p =
  MultiCpu
    ( mkArgs
        p
        [ "--template"
        , "<autoipat> <total>%"
        , "-L"
        , "50"
        , "-H"
        , "85"
        , "-w"
        , "3"
        ]
        [ "--fallback-icon-pattern"
        , "<icon=load_%%.xpm/>"
        , "--contiguous-icons"
        ]
    )
    10

cpuFreq p =
  CpuFreq
    ( p
        <~> [ "-t"
            , "<avg> <max> <min> <cpu0> <cpu1> <cpu2> <cpu3>"
            , "-L"
            , "1"
            , "-H"
            , "2"
            , "-S"
            , "Off"
            , "-d"
            , "2"
            ]
    )
    50

uptime p =
  Uptime
    ( p
        <~> [ "-t"
            , "<days> <hours>"
            , "-m"
            , "3"
            , "-c"
            , "0"
            , "-S"
            , "On"
            , "-L"
            , "10"
            , "-H"
            , "100"
            ]
    )
    600

-- https://erikflowers.github.io/weather-icons/
weather' tmp st p =
  WeatherX
    st
    [ -- ("", "\129695")
      -- , ("clear", "🔆")
      -- , ("sunny", "🔆")
      -- , ("fair", "🔆")
      -- , ("mostly clear", "🌤️")
      -- , ("mostly sunny", "🌤️")
      -- , ("partly sunny", "⛅")
      -- , ("obscured", "🌁")
      -- , ("fog", "🌫️")
      -- , ("foggy", "🌫️")
      -- , ("cloudy", "☁️")
      -- , ("overcast", "☁️")
      -- , ("partly cloudy", "⛅")
      -- , ("mostly cloudy", "☁️")
      -- , ("considerable cloudiness", "🌂")
      -- , ("light rain", "🌦️")
      -- , ("rain", "🌨️")
      -- , ("ice crystals", "❄️")
      -- , ("light snow", "🌨️")
      -- , ("snow", "❄️")
      ("", "\xf054")
    , ("clear", "\xf00d")
    , ("sunny", "\xf00d")
    , ("fair", "\xf00d")
    , ("mostly clear", "\xf00c")
    , ("mostly sunny", "\xf00c")
    , ("partly sunny", "\xf00c")
    , ("obscured", "\xf063")
    , ("fog", "\xf014")
    , ("foggy", "\xf014")
    , ("cloudy", "\xf041")
    , ("overcast", "\xf041")
    , ("partly cloudy", "\xf083")
    , ("mostly cloudy", "\xf013")
    , ("considerable cloudiness", "\xf002")
    , ("light rain", "\xf01c")
    , ("rain", "\xf019")
    , ("ice crystals", "\xf077")
    , ("light snow", "\xf01b")
    , ("snow", "\xf01b")
    ]
    ( mkArgs
        p
        ["-t", tmp, "-L", "10", "-H", "25", "-T", "20"]
        ["-w", ""]
    )
    18000

weather = weather' "<fn=2><skyConditionS></fn> <tempC>°  <windKmh> <weather>"

-- "https://wttr.in?format=" ++ fnn 3 "%c" ++ "+%t+%C+%w++" ++ fnn 1 "%m"
-- , Run (ComX "curl" [wttrURL "Edinburgh"] "" "wttr" 18000)
wttrURL l = "https://wttr.in/" ++ l ++ "?format=" ++ fmt
 where
  fmt = fnn 2 "+%c+" ++ "+%t+%C+" ++ fn 5 "%w"
  fnn n x = urlEncode ("<fn=" ++ show n ++ ">") ++ x ++ urlEncode "</fn>"
  encode c
    | c == ' ' = "+"
    | Char.isAlphaNum c || c `elem` "-._~" = [c]
    | otherwise = Printf.printf "%%%02X" c
  urlEncode = concatMap encode

batt p =
  BatteryN
    ["BAT0"]
    [ "-t"
    , "<acstatus> <left>"
    , "-S"
    , "Off"
    , "-d"
    , "0"
    , "-m"
    , "2"
    , "-L"
    , "10"
    , "-H"
    , "90"
    , "-p"
    , "2"
    , "--low"
    , pHigh p
    , "--normal"
    , pNormal p
    , "--high"
    , pLow p
    , "--"
    , "-P"
    , "-a"
    , "notify-send -u critical 'Battery running out!!!!!!'"
    , "-A"
    , "7"
    , "-i"
    , fn 1 "\9211"
    , "-O"
    , fn 1 " \9211" ++ " <timeleft> <watts>"
    , "-o"
    , fn 1 " 🔋" ++ " <timeleft> <watts>"
    , "-H"
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

iconBatt p =
  BatteryN
    ["BAT0"]
    [ "-t"
    , "<acstatus>"
    , "-S"
    , "Off"
    , "-d"
    , "0"
    , "-m"
    , "2"
    , "-L"
    , "10"
    , "-H"
    , "90"
    , "-p"
    , "2"
    , "-W"
    , "0"
    , "-f"
    , "\xf244\xf243\xf243\xf242\xf242\xf242\xf241\xf241\xf241\xf240"
    , "--low"
    , pHigh p
    , "--normal"
    , pNormal p
    , "--high"
    , pLow p
    , "--"
    , "-P"
    , "-a"
    , "notify-send -u critical 'Battery running out!!!!!!'"
    , "-A"
    , "5"
    , "-i"
    , fn 1 "\xf011"
    , "-O"
    , fn 1 "\xf1e6  <leftbar>" ++ " <left> <watts> <timeleft>"
    , "-o"
    , fn 1 "<leftbar>" ++ " <left> <watts> <timeleft>"
    , "-H"
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

rizenTemp p =
  K10Temp
    "0000:00:18.3"
    (mkArgs p ["-t", "<Tctl>°C", "-L", "40", "-H", "70", "-d", "0"] [])
    50

thinkTemp p =
  MultiCoreTemp
    ( mkArgs
        p
        ["-t", "<core1>°C", "-L", "40", "-H", "70", "-d", "0"]
        []
    )
    50

avgCoretemp p =
  MultiCoreTemp
    ( p
        <~> [ "-t"
            , "<avg>°"
            , "-L"
            , "50"
            , "-H"
            , "75"
            , "-d"
            , "0"
            ]
    )
    50

coreTemp p =
  MultiCoreTemp
    ( p
        <~> [ "-t"
            , "<avg>° <max>°"
            , "-L"
            , "50"
            , "-H"
            , "75"
            , "-d"
            , "0"
            ]
    )
    50

load p =
  Load
    (p <~> ["-t", "<load1> <load5> <load15>", "-L", "1", "-H", "3", "-d", "2"])
    300

diskU p =
  DiskU
    [("/", "<used>"), ("/media/sda", " s <used>")]
    (p <~> ["-L", "20", "-H", "70", "-m", "1", "-p", "3"])
    20

diskArgs p =
  mkArgs
    p
    [ "-f"
    , "░"
    , "-b"
    , " "
    , "-L"
    , "10000000"
    , "-H"
    , "100000000"
    , "-W"
    , "5"
    , "-w"
    , "5"
    , "-p"
    , "3"
    ]
    ["--total-icon-pattern", "<icon=load_%%.xpm/>", "-c"]

diskIO p =
  DiskIO [("rivendell-vg/root", "<readb> <writeb> <totalbipat>")] (diskArgs p) 10

mail p =
  MailX
    [ ("I", "jao/inbox", pHigh p)
    , ("b", "bigml/bugs", pHigh p)
    , ("B", "bigml/inbox", "")
    , ("S", "bigml/support", "")
    , ("H", "jao/hacking", "")
    , ("D", "jao/drivel", "")
    , ("D", "bigml/drivel", pDim p)
    , ("R", "feeds/rss", pDim p)
    , ("E", "feeds/emacs", pDim p)
    , ("P", "feeds/prog", pDim p)
    , ("B", "jao/bills", pDim p)
    , ("L", "bigml/lists", pDim p)
    ]
    ["-d", "~/var/mail", "-s", " "]
    "mail"

nmmail = NotmuchMail "mail" [MailItem "J" "" qj, MailItem "B" "" qb] 100
 where
  qb = "(tag:bigml or tag:alba) and tag:new"
  qj = "(tag:jao or tag:hacking or tag:bills) and tag:new"

masterVol p =
  Volume
    "default"
    "Master"
    [ "-t"
    , "<status> <volume>"
    , "--"
    , "-C"
    , pForeground p
    , "-c"
    , "#8b4726"
    , "-O"
    , fn 1 "\xf025"
    , "-o"
    , fn 1 "\xf131"
    ]
    10

captureVol = Volume "default" "Capture" ["-t", "<volume>"] 10

masterAlsa p =
  Alsa
    "default"
    "Master"
    [ "-t"
    , "<status> <volume>"
    , "--"
    , "-C"
    , pForeground p
    , "-c"
    , "#8b4726"
    , "-O"
    , fn 1 "\xf025"
    , "-o"
    , fn 1 "\xf131"
    ]

captureAlsa = Alsa "default" "Capture" ["-t", "<volume>"]

-- kbd p = Kbd [("us", "us"), ("us(intl)", "es")] -- kbi pDim
kbd p = Kbd [("us", ""), ("us(intl)", kbi pHigh)] -- kbi pDim
 where
  kbi a = fc (a p) (fn 1 " \xf11c")

brightness = Brightness ["--", "-D", "intel_backlight"] 10
brightness' = Brightness ["--", "-D", "amdgpu_bl0", "-C", "brightness"] 10

memory =
  Memory
    [ "-t"
    , "<used>:<available>"
    , "-p"
    , "2"
    , "-W"
    , "4"
    , "-d"
    , "1"
    , "--"
    , "--scale"
    , "1024"
    ]
    20

dynNetwork p =
  DynNetwork
    ( p
        <~> [ "-t"
            , fn 1 "↑ " ++ "<tx>  " ++ fn 1 "↓" ++ " <rx>"
            , "-L"
            , "20"
            , "-H"
            , "1024000"
            , "-m"
            , "5"
            , "-W"
            , "10"
            , "-S"
            , "Off"
            ]
    )
    10

netdev name icon = Network name ["-t", "<up>", "-x", "", "--", "--up", icon] 20
vpnMark n = netdev n $ fn 2 "🔒 " -- fni "\xf0e8 "
proton0 = vpnMark "proton0"
tun0 = vpnMark "tun0"

laTime = DateZone "%H" "" "America/Los_Angeles" "laTime" 10
localTime = Date "%a %d %R" "datetime" 10

trayPadding = Com "padding-width.sh" [] "tray" 20
