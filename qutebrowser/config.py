# Change the argument to True to still load settings configured via autoconfig.yml
config.load_autoconfig(False)
# HiDpi monitors
config.set('qt.highdpi', True)

# SETTINGS
# Cookies
# Valid values:
#   - all: Accept all cookies.
#   - no-3rdparty: Accept cookies from the same origin only. This is known to break some sites, such as GMail.
#   - no-unknown-3rdparty: Accept cookies from the same origin only, unless a cookie is already set for the domain. On QtWebEngine, this is the same as no-3rdparty.
#   - never: Don't accept cookies at all.
config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')

# User agent to send.
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {upstream_browser_key}/{upstream_browser_version} Safari/{webkit_version}', 'https://web.whatsapp.com/')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:71.0) Gecko/20100101 Firefox/71.0', 'https://accounts.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99 Safari/537.36', 'https://*.slack.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:71.0) Gecko/20100101 Firefox/71.0', 'https://docs.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:71.0) Gecko/20100101 Firefox/71.0', 'https://drive.google.com/*')

# Load images automatically in web pages.
config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')

# Enable JavaScript.
config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')

# # Security & privacy settings
# c.content.webgl = False
# c.content.dns_prefetch = False
# c.content.canvas_reading = False
# c.content.xss_auditing = True
# # "Do not track" is actually used to track you. Ironic, I know.
# c.content.headers.do_not_track = False
# # If you want privacy, you don't want anything web stored on your computer. No history, no cache, nothing. Take notes and make additional search engines. Quickmarks, bookmarks and cookies get deleted after a restart assuming you're using my wrapper script
# c.content.cache.appcache = False
# # c.content.local_storage = False
# # c.completion.web_history.max_items = 0
# # Cookies are blocked by Jmatrix, we leave them semi-enabled.
# c.content.cookies.accept = "no-3rdparty"
# # Private browsing does not work in single-process mode
# c.content.private_browsing = True
# # Why can't I just disable it, The-Compiler?
# c.content.webrtc_ip_handling_policy = "disable-non-proxied-udp"
#
# # adblock
# c.content.blocking.enabled = True
# c.content.blocking.method = 'both'
# c.content.blocking.adblock.lists = [
#         "https://easylist.to/easylist/easylist.txt",
#         "https://easylist.to/easylist/easyprivacy.txt",
#         "https://easylist.to/easylist/fanboy-social.txt",
#         "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
#         "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
#         "https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter.txt",
#         "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
#         "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-firstparty.txt",
#         "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-social.txt",
#         "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-specific.txt",
#         "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-sugarcoat.txt",
#         "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-firstparty-cname.txt",
#         "https://www.i-dont-care-about-cookies.eu/abp/",
#         "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"]

# Allow websites to show notifications.
# Type: BoolAsk
# Valid values:
#   - true
#   - false
#   - ask
config.set('content.notifications.enabled', True, 'https://www.reddit.com')
config.set('content.notifications.enabled', True, 'https://www.youtube.com')

# Search engines which can be used via the address bar.  Maps a search
# Type: Dict
c.url.searchengines = {'DEFAULT': 'https://www.google.com/search?q={}',
                       'am': 'https://www.amazon.com/s?k={}',
                       'aw': 'https://wiki.archlinux.org/?search={}',
                       'dd': 'https://duckduckgo.com/?kam=google-maps&kp=-2&q={}',
                       'gg': 'https://www.google.com/search?q={}',
                       'gh': 'https://github.com/search?q={}',
                       're': 'https://www.reddit.com/r/{}',
                       'yt': 'https://www.youtube.com/results?search_query={}',
                       'ul': 'https://ulozto.sk/hledej?q={}'
}

# Tabs
# show the tab bar.
c.tabs.show = 'multiple'
# open new tabs (middleclick/ctrl+click) in the background
c.tabs.background = True
# select previous tab instead of next tab when deleting current tab
c.tabs.select_on_remove = 'prev'
# open unrelated tabs after the current tab not last
c.tabs.new_position.unrelated = 'next'
c.tabs.min_width = 200

# FONTS
# default font families to use.
c.fonts.default_family = '"Hack Nerd Font Mono"'
# default font size to use.
c.fonts.default_size = '10pt'
# font used in the completion widget.
c.fonts.completion.entry = '10pt "Hack Nerd Font Mono"'
# font used for the debugging console.
c.fonts.debug_console = '10pt "Hack Nerd Font Mono"'
# font used for prompts.
c.fonts.prompts = '10pt "Hack Nerd Font Mono"'
# font used in the statusbar.
c.fonts.statusbar = '10pt "Hack Nerd Font Mono"'

# Home/Start Page
# c.url.default_page = 'https://start.duckduckgo.com/'
c.url.default_page = '/home/vimi/.config/qutebrowser/startpage/index.html'
c.url.start_pages = '/home/vimi/.config/qutebrowser/startpage/index.html'

# Downloads directory.
c.downloads.location.directory = '/home/vimi/Downloads'

# Scrollbar
# opt. always, never, when-serching, overlay
c.scrolling.bar = 'overlay'

# Statusbar.
# show always, never, in-mode
c.statusbar.show = 'in-mode'

# Dark mode
# c.colors.webpage.darkmode.policy.images = 'never'
# c.colors.webpage.darkmode.enabled = True
# c.colors.webpage.darkmode.policy.page = 'always'

# COLOR THEME
# base16-qutebrowser (https://github.com/theova/base16-qutebrowser)
# Scheme name: Kanagawa
# Scheme author: Tommaso Laurenzi (https://github.com/rebelot)
# Template author: theova and Daniel Mulford
# Commentary: Tinted Theming: (https://github.com/tinted-theming)

base00 = "#1f1f28"
base01 = "#16161d"
base02 = "#223249"
base03 = "#54546d"
base04 = "#727169"
base05 = "#dcd7ba"
base06 = "#c8c093"
base07 = "#717c7c"
base08 = "#c34043"
base09 = "#ffa066"
base0A = "#c0a36e"
base0B = "#76946a"
base0C = "#6a9589"
base0D = "#7e9cd8"
base0E = "#957fb8"
base0F = "#d27e99"

# set qutebrowser colors

# Text color of the completion widget. May be a single color to use for
# all columns or a list of three colors, one for each column.
c.colors.completion.fg = base05

# Background color of the completion widget for odd rows.
c.colors.completion.odd.bg = base00

# Background color of the completion widget for even rows.
c.colors.completion.even.bg = base00

# Foreground color of completion widget category headers.
c.colors.completion.category.fg = base0D

# Background color of the completion widget category headers.
c.colors.completion.category.bg = base00

# Top border color of the completion widget category headers.
c.colors.completion.category.border.top = base00

# Bottom border color of the completion widget category headers.
c.colors.completion.category.border.bottom = base00

# Foreground color of the selected completion item.
c.colors.completion.item.selected.fg = base05

# Background color of the selected completion item.
c.colors.completion.item.selected.bg = base02

# Top border color of the selected completion item.
c.colors.completion.item.selected.border.top = base02

# Bottom border color of the selected completion item.
c.colors.completion.item.selected.border.bottom = base02

# Foreground color of the matched text in the selected completion item.
c.colors.completion.item.selected.match.fg = base05

# Foreground color of the matched text in the completion.
c.colors.completion.match.fg = base09

# Color of the scrollbar handle in the completion view.
c.colors.completion.scrollbar.fg = base05

# Color of the scrollbar in the completion view.
c.colors.completion.scrollbar.bg = base00

# Background color of disabled items in the context menu.
c.colors.contextmenu.disabled.bg = base01

# Foreground color of disabled items in the context menu.
c.colors.contextmenu.disabled.fg = base04

# Background color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.bg = base00

# Foreground color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.fg =  base05

# Background color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.bg = base02

#Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.fg = base05

# Background color for the download bar.
c.colors.downloads.bar.bg = base00

# Color gradient start for download text.
c.colors.downloads.start.fg = base00

# Color gradient start for download backgrounds.
c.colors.downloads.start.bg = base0D

# Color gradient end for download text.
c.colors.downloads.stop.fg = base00

# Color gradient stop for download backgrounds.
c.colors.downloads.stop.bg = base0C

# Foreground color for downloads with errors.
c.colors.downloads.error.fg = base08

# Font color for hints.
c.colors.hints.fg = base00

# Background color for hints. Note that you can use a `rgba(...)` value
# for transparency.
c.colors.hints.bg = base0A

# Font color for the matched part of hints.
c.colors.hints.match.fg = base05

# Text color for the keyhint widget.
c.colors.keyhint.fg = base05

# Highlight color for keys to complete the current keychain.
c.colors.keyhint.suffix.fg = base05

# Background color of the keyhint widget.
c.colors.keyhint.bg = base00

# Foreground color of an error message.
c.colors.messages.error.fg = base00

# Background color of an error message.
c.colors.messages.error.bg = base08

# Border color of an error message.
c.colors.messages.error.border = base08

# Foreground color of a warning message.
c.colors.messages.warning.fg = base00

# Background color of a warning message.
c.colors.messages.warning.bg = base0E

# Border color of a warning message.
c.colors.messages.warning.border = base0E

# Foreground color of an info message.
c.colors.messages.info.fg = base05

# Background color of an info message.
c.colors.messages.info.bg = base00

# Border color of an info message.
c.colors.messages.info.border = base00

# Foreground color for prompts.
c.colors.prompts.fg = base05

# Border used around UI elements in prompts.
c.colors.prompts.border = base00

# Background color for prompts.
c.colors.prompts.bg = base00

# Background color for the selected item in filename prompts.
c.colors.prompts.selected.bg = base02

# Foreground color for the selected item in filename prompts.
c.colors.prompts.selected.fg = base05

# Foreground color of the statusbar.
c.colors.statusbar.normal.fg = base05

# Background color of the statusbar.
c.colors.statusbar.normal.bg = base00

# Foreground color of the statusbar in insert mode.
c.colors.statusbar.insert.fg = base0C

# Background color of the statusbar in insert mode.
c.colors.statusbar.insert.bg = base00

# Foreground color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.fg = base0A

# Background color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.bg = base00

# Foreground color of the statusbar in private browsing mode.
c.colors.statusbar.private.fg = base0E

# Background color of the statusbar in private browsing mode.
c.colors.statusbar.private.bg = base00

# Foreground color of the statusbar in command mode.
c.colors.statusbar.command.fg = base04

# Background color of the statusbar in command mode.
c.colors.statusbar.command.bg = base01

# Foreground color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.fg = base0E

# Background color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.bg = base01

# Foreground color of the statusbar in caret mode.
c.colors.statusbar.caret.fg = base0D

# Background color of the statusbar in caret mode.
c.colors.statusbar.caret.bg = base00

# Foreground color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.fg = base0D

# Background color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.bg = base00

# Background color of the progress bar.
c.colors.statusbar.progress.bg = base0D

# Default foreground color of the URL in the statusbar.
c.colors.statusbar.url.fg = base05

# Foreground color of the URL in the statusbar on error.
c.colors.statusbar.url.error.fg = base08

# Foreground color of the URL in the statusbar for hovered links.
c.colors.statusbar.url.hover.fg = base09

# Foreground color of the URL in the statusbar on successful load
# (http).
c.colors.statusbar.url.success.http.fg = base0B

# Foreground color of the URL in the statusbar on successful load
# (https).
c.colors.statusbar.url.success.https.fg = base0B

# Foreground color of the URL in the statusbar when there's a warning.
c.colors.statusbar.url.warn.fg = base0E

# Background color of the tab bar.
c.colors.tabs.bar.bg = base00

# Color gradient start for the tab indicator.
c.colors.tabs.indicator.start = base0D

# Color gradient end for the tab indicator.
c.colors.tabs.indicator.stop = base0C

# Color for the tab indicator on errors.
c.colors.tabs.indicator.error = base08

# Foreground color of unselected odd tabs.
c.colors.tabs.odd.fg = base05

# Background color of unselected odd tabs.
c.colors.tabs.odd.bg = base00

# Foreground color of unselected even tabs.
c.colors.tabs.even.fg = base05

# Background color of unselected even tabs.
c.colors.tabs.even.bg = base00

# Background color of pinned unselected even tabs.
c.colors.tabs.pinned.even.bg = base0B

# Foreground color of pinned unselected even tabs.
c.colors.tabs.pinned.even.fg = base00

# Background color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.bg = base0B

# Foreground color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.fg = base00

# Background color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.bg = base02

# Foreground color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.fg = base05

# Background color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.bg = base02

# Foreground color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.fg = base05

# Foreground color of selected odd tabs.
c.colors.tabs.selected.odd.fg = base05

# Background color of selected odd tabs.
c.colors.tabs.selected.odd.bg = base08

# Foreground color of selected even tabs.
c.colors.tabs.selected.even.fg = base05

# Background color of selected even tabs.
c.colors.tabs.selected.even.bg = base08

# Background color for webpages if unset (or empty to use the theme's
# color).
c.colors.webpage.bg = base00

# KEY Bindings
# play video from youtube in mpv
config.bind(';v', 'hint links spawn mpv-single {hint-url}')
# download video from youtube
config.bind(';d', 'hint links spawn kitty -e yt-dlp {hint-url} -P "$HOME/Downloads"')
# download video from ulozto
config.bind(';u', 'hint links spawn kitty -e ulozto-downloader --parts 50 --parts-progress --output /home/vimi/Downloads {hint-url}')
# show statusbar/tabs
config.bind('xb', 'config-cycle statusbar.show always never')
config.bind('xt', 'config-cycle tabs.show always never')
config.bind('xx', 'config-cycle statusbar.show always never;; config-cycle tabs.show always never')
# open new private window
config.bind('tp', 'open -p')
# config.bind('t', 'set-cmd-text -s :open -t')
# reload configuration
config.bind('R', 'config-source')
# tab movemend
config.bind('<Alt+LEFT>', 'tab-prev')
config.bind('<Alt+RIGHT>', 'tab-next')
# clear history
config.bind('ch', 'history-clear')
