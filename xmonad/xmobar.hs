Config 
  { position = TopP 0 0,
    font = "xft:Iosevka:Style=bold:pixelsize=15:antialias=true:hinting=true",
    additionalFonts =
      ["xft:FontAwesome:pixelsize=13"],
    bgColor = "#222222",
    fgColor = "#DDDDDD",
    lowerOnStart = True,
    hideOnStart = False,
    overrideRedirect = False,
    allDesktops = False,
    persistent = True,
    iconRoot = "/home/xiuxiu/.config/xmonad/img/",
    commands =
      [ Run UnsafeStdinReader,
        -- Run StdinReader,
        Run Date " <fn=1>\xf133</fn> %a %b %_d %l:%M:%S" "date" 10,
        Run Com "/home/xiuxiu/.local/scripts/pacupdate.sh" [] "pacupdate" 600,
        Run Memory ["-t", "Mem <usedratio>%", "-H", "8192", "-L", "4096", "-h", "#e06c75", "-l", "#98c379", "-n", "#e06c75"] 20,
        Run Swap ["-t", "Swap <usedratio>%", "-H", "1024", "-L", "512", "#e06c75", "-l", "#98c379", "-n", "#e06c75"] 20,
        Run
          MultiCpu
          [ "-t",
            "Cpu<total0><total1><total2><total3><total4><total5><total6><total7>\
            \<total8><total9><total10><total11><total12><total13><total14><total15>",
            "-L",
            "30",
            "-H",
            "60",
            "-h",
            "#e06c75",
            "-l",
            "#98c379",
            "-n",
            "#e06c75",
            "-w",
            "3"
          ]
          20
      ],
    sepChar = "%",
    alignSep = "}{",
    template = " <icon=haskell.xpm/> <fc=#98c379>%UnsafeStdinReader%</fc> } <fc=#56b6c2>%date%</fc> { <fc=#e06c75><fn=1></fn> %pacupdate%</fc> <fc=#666666>|</fc> <fc=#c678dd>%multicpu%</fc> <fc=#666666>|</fc> <fc=#46d9ff>%memory%</fc> "
  }

