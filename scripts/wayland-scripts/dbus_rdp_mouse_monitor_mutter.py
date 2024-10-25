#!/usr/bin/python3

import sys
import signal
import dbus
import time
from gi.repository import GLib
from dbus.mainloop.glib import DBusGMainLoop
from functools import partial

import gi
gi.require_version('Gst', '1.0')
from gi.repository import GObject, Gst

pipeline = None

def terminate():
    global pipeline
    print("pipeline: " + str(pipeline))
    if pipeline is not None:
        print("draining pipeline")
        pipeline.send_event(Gst.Event.new_eos())
        pipeline.set_state(Gst.State.NULL)
    print("stopping")
    

def on_message(bus, message, monitor_idx):
    global pipeline
    type = message.type
    print("message pipeline: " + str(pipeline))
    if type == Gst.MessageType.EOS or type == Gst.MessageType.ERROR:
        terminate()
        #screen_cast_session.Stop(dbus_interface=screen_cast_session_iface)
        rdp_session.Stop(dbus_interface=rdp_session_iface)
        loop.quit()

def on_pipewire_stream_added(node_id, stream_path):
    global pipeline
    print("added", node_id)

    format_element = "video/x-raw,max-framerate=%d/1,width=%d,height=%d !"%(
      int(60), int(1920), int(1080))
    pipeline = Gst.parse_launch('pipewiresrc path=%u ! %s videoconvert'%(
        node_id, format_element))
    pipeline.set_state(Gst.State.PLAYING)
    pipeline.get_bus().connect('message', on_message)
    time.sleep(3)
    rdp_session.NotifyPointerMotionAbsolute(stream_path,100, 100, dbus_interface=rdp_session_iface)

DBusGMainLoop(set_as_default=True)
Gst.init(None)

loop = GLib.MainLoop()

bus = dbus.SessionBus()
rdp_iface = 'org.gnome.Mutter.RemoteDesktop'
rdp_session_iface = 'org.gnome.Mutter.RemoteDesktop.Session'

screen_cast_iface = 'org.gnome.Mutter.ScreenCast'
screen_cast_session_iface = 'org.gnome.Mutter.ScreenCast.Session'

rdp = bus.get_object(rdp_iface,
                             '/org/gnome/Mutter/RemoteDesktop')
screen_cast = bus.get_object(screen_cast_iface,
                             '/org/gnome/Mutter/ScreenCast')
rdp_session_path = rdp.CreateSession(dbus_interface=rdp_iface)
rdp_session = bus.get_object(rdp_iface, rdp_session_path)
rdp_session_props = dbus.Interface(rdp_session, dbus.PROPERTIES_IFACE)
rdp_session_id = rdp_session_props.Get(rdp_session_iface, 'SessionId')

screen_cast_session_path = screen_cast.CreateSession(dbus.Dictionary({'remote-desktop-session-id': dbus.String(rdp_session_id, variant_level=1),
                                                                      'disable-animations': dbus.Boolean(False, variant_level=1)}, signature='sv'), dbus_interface=screen_cast_iface)
screen_cast_session = bus.get_object(screen_cast_iface, screen_cast_session_path)
#screen_cast_session_props = dbus.Interface(screen_cast_session, dbus.PROPERTIES_IFACE)
#screen_cast_streams = screen_cast_session_props.Get(screen_cast_session_iface, 'Streams')
print("session paths: %s, %s"%(rdp_session_path,screen_cast_session_path))
print("RDP session ID:", rdp_session_id)


stream_path = screen_cast_session.RecordVirtual(
    dbus.Dictionary({'is-platform': dbus.Boolean(True, variant_level=1),
                     'cursor-mode': dbus.UInt32(1, variant_level=1)}, signature='sv'),
    dbus_interface=screen_cast_session_iface)
stream = bus.get_object(screen_cast_iface, stream_path)
stream.connect_to_signal("PipeWireStreamAdded", partial(on_pipewire_stream_added, stream_path=stream_path))
print("Stream path:", stream_path)

rdp_session.Start(dbus_interface=rdp_session_iface)
#screen_cast_session.Start(dbus_interface=screen_cast_session_iface)

try:
    loop.run()
except KeyboardInterrupt:
    print("interrupted")
    terminate()
    #screen_cast_session.Stop(dbus_interface=screen_cast_session_iface)
    rdp_session.Stop(dbus_interface=rdp_session_iface)
    loop.quit()

