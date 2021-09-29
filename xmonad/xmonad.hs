-- import Graphics.X11.ExtraTypes.XF86

import Data.Array
import qualified Data.Map as M
import Data.Maybe (fromJust, isJust)
import Data.Monoid
import Data.String
import System.Exit
import System.IO
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Decoration (ModifiedLayout)
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps (Gaps, gaps)
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as W
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Themes

_modMask :: KeyMask
_modMask = mod4Mask

_terminal :: String
_terminal = "alacritty"

_xmobar :: String
_xmobar = "~/.config/xmonad/xmobar.hs"

_workspaces :: [String]
_workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

_focusFollowsMouse :: Bool
_focusFollowsMouse = True

_clickJustFocuses :: Bool
_clickJustFocuses = False

_normalBorderColor :: String
_normalBorderColor = "#6e4a94"

_focusedBorderColor :: String
_focusedBorderColor = "#dddddd"

_xmobarTitleColor :: String
_xmobarTitleColor = "FFB6B0"

_xmobarCurrentWorkspaceColor :: String
_xmobarCurrentWorkspaceColor = "CEFFAC"

_defaultGaps :: [(Direction2D, Int)]
_defaultGaps = [(U, 15), (D, 15), (R, 15), (L, 15)]

_borderWidth :: Dimension
_borderWidth = 0

_keys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
_keys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      ((modm .|. shiftMask, xK_p), spawn "dmenu_run"),
      ((modm .|. shiftMask, xK_w), spawn "firefox"),
      ((modm .|. shiftMask, xK_e), spawn "emacs"),
      ((modm .|. shiftMask, xK_s), spawn "spotify"),
      ((modm .|. shiftMask, xK_d), spawn "discord"),
      ((modm, xK_space), sendMessage NextLayout), -- Cycle layout
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf), -- Default layotu
      ((modm .|. shiftMask, xK_c), kill),
      ((modm, xK_n), refresh),
      -- Move
      ((modm, xK_Tab), windows W.focusDown),
      ((modm, xK_j), windows W.focusDown),
      ((modm, xK_k), windows W.focusUp),
      ((modm, xK_m), windows W.focusMaster),
      -- Swap focused with master
      ((modm, xK_Return), windows W.swapMaster),
      -- Swap focused with next
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap focused window with previous
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Resize master
      ((modm, xK_h), sendMessage Shrink),
      ((modm, xK_l), sendMessage Expand),
      -- Push back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Number in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      ((modm, xK_z), spawn "xmonad --recompile && xmonad --restart"), -- Restart
      ((modm .|. shiftMask, xK_z), io exitSuccess) -- Exit
    ]
      ++
      -- mod-shift-{u, i, o}, Move client to screen L, M, or R
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_i, xK_o, xK_u] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

_mouse :: XConfig l -> M.Map (KeyMask, Button) (Window -> X ())
_mouse XConfig {XMonad.modMask = modm} =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        \w ->
          focus w >> mouseMoveWindow w
            >> windows W.shiftMaster
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), \w -> focus w >> windows W.shiftMaster),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        \w ->
          focus w >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
    ]

_manageHook :: ManageHook
_manageHook =
  composeAll
    [ manageDocks,
      className =? "Vlc" --> doFullFloat,
      className =? "gmrun" --> doFullFloat,
      isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ]

_eventHook :: Event -> X All
_eventHook = mempty

_startupHook :: X ()
_startupHook = mempty

_layoutHook =
  avoidStruts $
    noBorders $
      gaps
        _defaultGaps
        ( tiled
            ||| Mirror tiled
            ||| Full
        )
        ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 1 / 2
    delta = 3 / 100
    theme = darkTheme

_logHook :: X ()
_logHook = return ()

defaults ::
  XConfig
    ( ModifiedLayout
        AvoidStruts
        ( ModifiedLayout
            WithBorder
            ( Choose
                (ModifiedLayout Gaps (Choose Tall (Choose (Mirror Tall) Full)))
                Full
            )
        )
    )
defaults =
  def
    { terminal = _terminal,
      focusFollowsMouse = _focusFollowsMouse,
      clickJustFocuses = _clickJustFocuses,
      borderWidth = _borderWidth,
      modMask = _modMask,
      workspaces = _workspaces,
      normalBorderColor = _normalBorderColor,
      focusedBorderColor = _focusedBorderColor,
      keys = _keys,
      mouseBindings = _mouse,
      layoutHook = _layoutHook,
      manageHook = _manageHook,
      handleEventHook = _eventHook,
      logHook = _logHook,
      startupHook = _startupHook
    }

main :: IO ()
main = do
  xmproc <- spawnPipe ("xmobar " ++ _xmobar)
  xmonad $
    docks
      defaults
        { manageHook = manageDocks <+> _manageHook,
          startupHook = _startupHook,
          handleEventHook = docksEventHook,
          logHook =
            dynamicLogWithPP $
              xmobarPP
                { ppOutput = hPutStrLn xmproc,
                  ppTitle = xmobarColor _xmobarTitleColor "" . shorten 100,
                  ppCurrent = xmobarColor _xmobarCurrentWorkspaceColor "",
                  ppSep = "   "
                }
        }
