#!/usr/bin/python3

# Screens config: Set virtual screens as tuples (width, height, refresh rate)
# THIS IS THE ONLY LINE THAT YOU NEED TO EDIT IN THIS CODE
monitors_config=[(1920,1080,60),(1920,1080,60),(1920,1080,60)]

import sys
import signal
import dbus
from gi.repository import GLib
from dbus.mainloop.glib import DBusGMainLoop
from functools import partial

import gi
gi.require_version('Gst', '1.0')
from gi.repository import GObject, Gst

DBusGMainLoop(set_as_default=True)
Gst.init(None)

loop = GLib.MainLoop()

bus = dbus.SessionBus()
screen_cast_iface = 'org.gnome.Mutter.ScreenCast'
screen_cast_session_iface = 'org.gnome.Mutter.ScreenCast.Session'

screen_cast = bus.get_object(screen_cast_iface,
                             '/org/gnome/Mutter/ScreenCast')
session_path = screen_cast.CreateSession([], dbus_interface=screen_cast_iface)
print("session path: %s"%session_path)
session = bus.get_object(screen_cast_iface, session_path)

streams=[]
pipelines=[]

def terminate(monitor_idx):
    global pipelines
    print("pipeline: " + str(pipelines[monitor_idx]))
    if pipelines[monitor_idx] is not None:
        print("draining pipeline")
        pipelines[monitor_idx].send_event(Gst.Event.new_eos())
        pipelines[monitor_idx].set_state(Gst.State.NULL)
    print("stopping")
    

def on_message(bus, message, monitor_idx):
    global pipelines
    type = message.type
    print("message pipeline: " + str(pipelines[monitor_idx]))
    if type == Gst.MessageType.EOS or type == Gst.MessageType.ERROR:
        partial(terminate, monitor_idx=monitor_idx)
        session.Stop(dbus_interface=screen_cast_session_iface)
        loop.quit()

def on_pipewire_stream_added(node_id, monitor_idx):
    global pipelines
    global monitors_config
    print("added", monitors_config[monitor_idx])

    format_element = "video/x-raw,max-framerate=%d/1,width=%d,height=%d !"%(
      int(monitors_config[monitor_idx][2]), int(monitors_config[monitor_idx][0]), int(monitors_config[monitor_idx][1]))
    #pipelines[monitor_idx] = Gst.parse_launch('pipewiresrc path=%u ! %s videoconvert'%(
    pipelines[monitor_idx] = Gst.parse_launch('pipewiresrc path=%u ! %s videoconvert ! glimagesink'%(
        node_id, format_element))
    pipelines[monitor_idx].set_state(Gst.State.PLAYING)
    pipelines[monitor_idx].get_bus().connect('message', partial(on_message, monitor_idx=monitor_idx))

for cfg, idx in zip(monitors_config, range(len(monitors_config))):
  stream_path = session.RecordVirtual(
      dbus.Dictionary({'is-platform': dbus.Boolean(True, variant_level=1),
                       'cursor-mode': dbus.UInt32(2, variant_level=1)}, signature='sv'),
      dbus_interface=screen_cast_session_iface)
  streams.append(bus.get_object(screen_cast_iface, stream_path))
  pipelines.append(None)
  streams[-1].connect_to_signal("PipeWireStreamAdded", partial(on_pipewire_stream_added, monitor_idx=idx))

session.Start(dbus_interface=screen_cast_session_iface)

try:
    loop.run()
except KeyboardInterrupt:
    print("interrupted")
    for idx in range(len(monitors_config)):
      terminate(idx)
    session.Stop(dbus_interface=screen_cast_session_iface)
    loop.quit()

