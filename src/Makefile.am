bin_PROGRAMS = upnp-browse

upnp_browse_SOURCES = \
	browse-command.vala \
	browse-path.vala \
	browse.vala \
	cd-command.vala \
	command.vala \
	connect-command.vala \
	content-directory.vala \
	disconnect-command.vala \
	info-command.vala \
	list-command.vala \
	search-command.vala \
	upnp-device-lister.vala

upnp_browse_VALAFLAGS = \
	--pkg gupnp-1.0 \
	--pkg gupnp-av-1.0 \
	--pkg readline

upnp_browse_CFLAGS = \
	$(GUPNP_CFLAGS)

upnp_browse_LDADD = \
	$(GUPNP_LIBS) \
	$(READLINE_LIBS)
