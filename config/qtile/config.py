import os, subprocess
from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from colors import kanagawa
from datetime import datetime, date, timezone

### MY BASIC APP ###

mod = "mod4"
mod1 = "alt"
mod2 = "control"
myTerminal = "kitty"
# myBrowser = "firefox"
myBrowser = "brave-browser"
myTextEditor = myTerminal + " nvim"
myFileManager = myTerminal + " ranger"
myVideoPlayer = "mpv --player-operation-mode=pseudo-gui"
myEmail = "thunderbird"
myCity= "Bratislava"
myFonts = "Hack Nerd Font"
myMenu = "rofi -show drun"
myScreenshot = "flameshot gui"

### KEYS ###

keys = [
    # RUN TERMINAL
    Key([mod], "Return", lazy.spawn(myTerminal)),

    # RUN SPAWN CMD PROMPT / ROFI
    # Key([mod], "r", lazy.spawncmd()),
    Key([mod], "r", lazy.spawn(myMenu), desc="Rofi menu"),

    # KILL WINDOW
    Key([mod], "w", lazy.window.kill()),

    # RELOAD QTILE CONFIG
    Key([mod, "control"], "r", lazy.reload_config()),

    # SHUTDOWN QTILE
    Key([mod, "shift"], "q", lazy.spawn("systemctl poweroff")),

    # RESTART QTILE
    Key([mod, "shift"], "r", lazy.spawn("systemctl reboot")),

    # SWITCH FOCUS
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Right", lazy.layout.right()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Up", lazy.layout.up()),
    Key([mod], "space", lazy.layout.next(), desc="Focus to other window"),

    # MOVE LEFT, RIGHT, UP, DOWN
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),

    # RESIZE LEFT, RIGHT, UP, DOWN
    Key([mod, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "Left",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "Right",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),
    Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # TOGGLE BETWEEN SPLIT AND UNSPLIT SIDES OF STACK
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),

    # TOGGLE BETWEEN DIFFERENT LAYOUTS
    Key([mod], "Tab", lazy.next_layout()),

    # TOGGLE FLOATING LAYOUT
    Key([mod], "t", lazy.window.toggle_floating()),

    # TOGGLE FULSCREEN
    Key([mod], "f", lazy.window.toggle_fullscreen()),

    Key([mod, "control"], "space", lazy.layout.flip(), desc="Flip main side"),
    Key([mod, "control"], "m", lazy.window.toggle_minimize(), desc="Toggle minimize"),
    Key([mod, "shift"], "m", lazy.window.toggle_maximize(), desc="Toggle maximize"),

    # VOLUME
    Key([], "XF86AudioLowerVolume", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/volume.sh lower")), desc="Volume Down"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/volume.sh raise")), desc="Volume Up"),
    Key([], "XF86AudioMute", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/volume.sh mute")), desc="Volume Mute"),
    # Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2%"), desc="Volume Down"),
    # Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2%"), desc="Volume Up"),
    # Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Volume Mute"),
    # Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer -d 2"), desc="Volume Down"),
    # Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer -i 2"), desc="Volume Up"),
    # Key([], "XF86AudioMute", lazy.spawn("pamixer -t"), desc="Volume Mute"),

    # BRIGTHNESS
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s 10%+"), desc="Brightness Up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 10%-"), desc="Brightness Down"),

    # PLAYERCTL
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Playerctl Play/Pause"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Playerctl Prev"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Playerctl Next"),

    # MY APPLICATIONS
    # Key([mod, "shift"], "v", lazy.spawn(myVideoPlayer + " /home/vimi/Downloads/"), desc="Launch mpv"),
    KeyChord([mod], "b", [
        Key([], "b", lazy.spawn(myBrowser), desc="Launch Brave"),
        Key([], "f", lazy.spawn("firefox -private-window"), desc="Launch Firefox"),
        Key([], "q", lazy.spawn("qutebrowser"), desc="Launch Qutebrowser")
        ]),
    Key([mod], "v", lazy.spawn(myTextEditor), desc="Launch Neovim"),
    Key([mod], "e", lazy.spawn(myFileManager), desc="Launch Ranger"),
    Key([mod, "shift"], "s", lazy.spawn(os.path.expanduser(myScreenshot)), desc="Flameshot"),
    Key([mod, "shift"], "t", lazy.spawn("translate"), desc="Translate"),
    Key([mod, "shift"], "m", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/monitor.sh toggle_monitor")), desc="Toggle Monitor"),
    Key([mod], "n", lazy.spawn("redshift -O 3400"), desc="Redshift enable"),
    Key([mod, "shift"], "n", lazy.spawn("redshift -x"), desc="Redshift disable"),
    Key([mod], "space", lazy.widget["keyboardlayout"].next_keyboard(), desc="Next keyboard layout."),
]

### GROUPS ###

groups = [
        Group("1", label="", layout="monadtall"),
        Group("2", label="", layout="monadtall"),
        Group("3", label="", layout="monadtall"),
        Group("4", label="", layout="monadtall",
              matches=[
                  Match(wm_class=["Inkscape"]),
                  Match(wm_class=["FreeCAD"]),
                  Match(wm_class=["salome_meca"])],
              ),
        Group("5", label="", layout="monadtall",
              matches=[
                  Match(wm_class=["JDownloader"])],
              ),
]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod],
            i.name,
            lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),
        # mod1 + shift + letter of group = switch & move focused window to group
        Key([mod, "shift"],
            i.name,
            lazy.window.togroup(i.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(i.name)),
    ])


### LAYOUTS ###

layout_config = {
        "border_width":1,
        "single_border_width":0,
        "margin":0,
        "border_focus":kanagawa["red"],
        "border_normal":kanagawa["grey"],
        }

layouts = [
    layout.Columns(**layout_config),
    layout.Max(),
    layout.MonadTall(**layout_config),
]

floating_layout = layout.Floating(
    **layout_config,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry

        Match(wm_class="pavucontrol"),
    ]
    )

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


### WIDGETS ###

widget_defaults = dict(
    font="Open Sans",
    fontsize=18,
    padding=5,
    foreground=kanagawa["fg"],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        wallpaper='~/.config/qtile/wallpapers/mountains-orange.png',
        wallpaper_mode='fill',
        top=bar.Bar(
            [
                widget.Spacer(
                    length=5,
                ),
                widget.GroupBox(
                    padding=3,
                    highlight_method="text",
                    this_current_screen_border=kanagawa["red"],
                    active=kanagawa["fg"],
                    inactive=kanagawa["grey"],
                    urgent_alert_method=["text"],
                    urgent_border=kanagawa["magenta"],
                ),
                widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                    scale=0.5,
                    ),
                widget.Prompt(),
                widget.WindowName(),
                # widget.TaskList(),
                widget.Systray(),
                widget.Spacer(
                    length=10,
                ),
                widget.TextBox(
                    text="墳",
                    font=myFonts,
                    foreground=kanagawa["blue"],
                    ),
                widget.Volume(
                    mouse_callbacks={
                        "Button1": lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
                        "Button3": lazy.spawn("pavucontrol")
                        },
                ),
                widget.Spacer(
                    length=10,
                ),
                # widget.TextBox(
                #     text="",
                #     font=myFonts,
                #     foreground=kanagawa["blue"],
                #     ),
                # widget.ThermalSensor(
                #     tag_sensor="CPU",
                #     threshold=80,
                #     foreground_alert=kanagawa["red"],
                # ),
                # widget.Spacer(
                #     length=5,
                # ),
                # widget.TextBox(
                #     text="",
                #     font=myFonts,
                #     foreground=kanagawa["blue"],
                # ),
                # widget.Spacer(
                #     length=5,
                # ),
                # widget.CPU(
                #     format="{load_percent}% |",
                #     mouse_callbacks={"Button1": lazy.spawn(myTerminal + " -e htop")},
                #     padding=0,
                # ),
                # widget.Memory(
                #     format="{MemUsed: .0f}{mm}",
                #     mouse_callbacks={"Button1": lazy.spawn(myTerminal + " -e htop")},
                #     measure_mem="M",
                #     padding=0,
                # ),
                # widget.Spacer(
                #     length=5,
                # ),
                # widget.TextBox(
                #     text=" ",
                #     # text="摒",
                #     font=myFonts,
                #     foreground=kanagawa["blue"],
                # ),
                # widget.OpenWeather(
                #     location=myCity,
                #     font=myFonts,
                #     format="{main_temp}°{units_temperature}",
                # ),
                # widget.Spacer(
                #     length=5,
                # ),
                widget.TextBox(
                    text="",
                    font=myFonts,
                    foreground=kanagawa["blue"],
                ),
                widget.KeyboardLayout(
                    configured_keyboards=['us', 'sk'],
                    mouse_callbacks={
                        'Button1': lazy.widget["keyboardlayout"].next_keyboard(),
                        },
                ),
                widget.Spacer(
                    length=10,
                ),
                # widget.TextBox(
                #     text="",
                #     font=myFonts,
                #     foreground=kanagawa["blue"],
                # ),
                # widget.Clock(
                #     # format="%d.%m.%Y | %a",
                #     format="%d.%m.%Y",
                # ),
                # widget.Spacer(
                #     length=5,
                # ),
                widget.TextBox(
                    text="",
                    font=myFonts,
                    foreground=kanagawa["blue"],
                ),
                 widget.Clock(
                    format="%H:%M",
                    mouse_callbacks={
                        'Button1': lazy.spawn(f"dunstify '{datetime.now().date().strftime('%d.%m.%Y %A')}'")
                        },
                ),
                widget.Spacer(
                    length=10,
                ),
                widget.QuickExit(
                    default_text="",
                    font=myFonts,
                    fontsize=20,
                    countdown_start=1,
                    foreground=kanagawa["red"],
                    mouse_callbacks={
                        'Button1': lazy.spawn("power-menu"),
                        # 'Button1': lazy.spawn("systemctl poweroff"),
                        # 'Button3': lazy.spawn("systemctl reboot")
                        },
                ),
                widget.Spacer(
                    length=10,
                ),
            ],
            28,
            background=kanagawa["dark_bg"],
        ),
    ),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False


### AUTOSTART ###

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])

# @hook.subscribe.screen_change
# def restart_on_randr():
#     home = os.path.expanduser('~/.config/qtile/monitor.sh')
#     subprocess.call([home])

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
