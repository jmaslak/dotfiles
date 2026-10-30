# Add x3270's bitmap fonts (3270, 3270gt32, etc.) to the X font path
# Sourced by XQuartz's xinitrc.d/98-user.sh at X server startup
if [ -e /usr/local/share/fonts/X11/misc/fonts.dir ] ; then
    /opt/X11/bin/xset +fp /usr/local/share/fonts/X11/misc/
    /opt/X11/bin/xset fp rehash
fi
