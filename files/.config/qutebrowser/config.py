# Managed by Home Manager — do not edit in-place if you version it!

# -----------------------------------------------------------------------------
# Load settings configured via UI?
# -----------------------------------------------------------------------------
# We keep this OFF so qutebrowser doesn’t write/expect autoconfig.yml.
config.load_autoconfig(False)

# -----------------------------------------------------------------------------
# General UI / behavior
# -----------------------------------------------------------------------------
c.auto_save.session = True                 # restore last session on startup (see :wq / :quit)
c.confirm_quit = ["downloads"]             # be polite on quit
c.scrolling.smooth = True
c.zoom.default = "110%"

# Tabs
c.tabs.position = "top"
c.tabs.show = "multiple"
c.tabs.favicons.show = "always"
c.tabs.padding = {"top": 6, "bottom": 6, "left": 8, "right": 8}

# Statusbar & messages
c.messages.timeout = 4000

# Start/home pages
c.url.start_pages = ["https://duckduckgo.com"]
c.url.default_page = "https://duckduckgo.com"

# -----------------------------------------------------------------------------
# Search engines
# -----------------------------------------------------------------------------
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g":       "https://www.google.com/search?q={}",
    "w":       "https://en.wikipedia.org/wiki/Special:Search?search={}",
    "gh":      "https://github.com/search?q={}",
    "r":       "https://www.reddit.com/search/?q={}",
    "yt":      "https://www.youtube.com/results?search_query={}",
    "so":      "https://stackoverflow.com/search?q={}",
}

# -----------------------------------------------------------------------------
# Downloads
# -----------------------------------------------------------------------------
c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False
c.downloads.remove_finished = 30000  # ms

# -----------------------------------------------------------------------------
# Editor (open text areas with your editor)
# -----------------------------------------------------------------------------
# Uses kitty + nvim, matching your setup. Change if you prefer something else.
c.editor.command = ["kitty", "-e", "nvim", "{file}"]
c.editor.encoding = "utf-8"

# -----------------------------------------------------------------------------
# Content / privacy
# -----------------------------------------------------------------------------
c.content.autoplay = False
c.content.blocking.enabled = True
c.content.blocking.method = "auto"   # auto-select available adblock backends
c.content.default_encoding = "utf-8"

# Dark mode (Qt’s force-dark; not perfect everywhere)
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True

# Do Not Track
c.content.headers.do_not_track = True

# Geolocation / notifications: prompt by default; you can force-deny if you like
# config.set("content.geolocation", False, "*")
# config.set("content.notifications.enabled", False, "*")

# -----------------------------------------------------------------------------
# Key bindings
# -----------------------------------------------------------------------------
# Vim-like tab navigation
config.bind("J", "tab-prev")
config.bind("K", "tab-next")

# Quick open downloads
config.bind(",d", "download-open")

# Yank current page URL/title
config.bind("yY", "yank title")
config.bind("yu", "yank url")

# External helpers (optional)
# Open current page in mpv (uncomment if you use mpv)
# config.bind(",m", "spawn --detach mpv {url}")

# Open current page in system browser
# config.bind(",b", "spawn --detach xdg-open {url}")

# -----------------------------------------------------------------------------
# Site-specific overrides (examples)
# -----------------------------------------------------------------------------
# Example: force-disable JavaScript on a domain
# config.set("content.javascript.enabled", False, "https://example.com/*")

# Example: enable notifications on a trusted site
# config.set("content.notifications.enabled", True, "https://calendar.google.com/*")
