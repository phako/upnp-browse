project('upnp-browse', ['vala', 'c'],
        version: '0.1')

cc = meson.get_compiler('c')
readline = cc.find_library('readline')
gobject = dependency('gobject-2.0')
ssdp = dependency('gssdp-1.0')
upnp = dependency('gupnp-1.0')
upnp_av = dependency('gupnp-av-1.0')

subdir('src')
