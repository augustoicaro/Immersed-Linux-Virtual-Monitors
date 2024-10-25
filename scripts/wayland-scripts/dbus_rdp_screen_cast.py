#!/usr/bin/python3

import re
import signal
import dbus
from gi.repository import GLib
from dbus.mainloop.glib import DBusGMainLoop

import gi
gi.require_version('Gst', '1.0')
from gi.repository import GObject, Gst

DBusGMainLoop(set_as_default=True)
Gst.init(None)

loop = GLib.MainLoop()

bus = dbus.SessionBus()
request_iface = 'org.freedesktop.portal.Request'
screen_cast_iface = 'org.freedesktop.portal.ScreenCast'
remote_desktop_iface = 'org.freedesktop.portal.RemoteDesktop'

pipeline = None

def terminate():
    if pipeline is not None:
        self.player.set_state(Gst.State.NULL)
    loop.quit()

request_token_counter = 0
session_token_counter = 0
sender_name = re.sub(r'\.', r'_', bus.get_unique_name()[1:])

def new_request_path():
    global request_token_counter
    request_token_counter = request_token_counter + 1
    token = 'u%d'%request_token_counter
    path = '/org/freedesktop/portal/desktop/request/%s/%s'%(sender_name, token)
    return (path, token)

def new_session_path():
    global session_token_counter
    session_token_counter = session_token_counter + 1
    token = 'u%d'%session_token_counter
    path = '/org/freedesktop/portal/desktop/session/%s/%s'%(sender_name, token)
    return (path, token)

def remote_desktop_call(method, callback, *args, options={}):
    (request_path, request_token) = new_request_path()
    bus.add_signal_receiver(callback,
                            'Response',
                            request_iface,
                            'org.freedesktop.portal.Desktop',
                            request_path)
    options['handle_token'] = request_token
    method(*(args + (options, )),
           dbus_interface=remote_desktop_iface)

def screen_cast_call(method, callback, *args, options={}):
    (request_path, request_token) = new_request_path()
    bus.add_signal_receiver(callback,
                            'Response',
                            request_iface,
                            'org.freedesktop.portal.Desktop',
                            request_path)
    options['handle_token'] = request_token
    method(*(args + (options, )),
           dbus_interface=screen_cast_iface)

def on_gst_message(bus, message):
    type = message.type
    if type == Gst.MessageType.EOS or type == Gst.MessageType.ERROR:
        terminate()

def play_pipewire_stream(node_id):
    empty_dict = dbus.Dictionary(signature="sv")
    fd_object = portal.OpenPipeWireRemote(session, empty_dict,
                                          dbus_interface=screen_cast_iface)
    fd = fd_object.take()
    pipeline = Gst.parse_launch('pipewiresrc fd=%d path=%u ! videoconvert ! xvimagesink'%(fd, node_id))
    pipeline.set_state(Gst.State.PLAYING)
    pipeline.get_bus().connect('message', on_gst_message)

def on_start_response(response, results):
    if response != 0:
        print("Failed to start: %s"%response)
        terminate()
        return

    print("streams:")
    for (node_id, stream_properties) in results['streams']:
        print("stream {}".format(node_id))
        play_pipewire_stream(node_id)

def on_rd_select_sources_response(response, results):
    if response != 0:
        print("Failed to select sources: %d"%response)
        terminate()
        return

    print("sources selected", results)
    global session
    remote_desktop_call(portal.Start, on_start_response,
                        session, '')

def on_create_session_response(response, results):
    if response != 0:
        print("Failed to create session: %d"%response)
        terminate()
        return

    global session
    print(results)
    print("session %s created"%session)

    screen_cast_call(portal.SelectSources, on_rd_select_sources_response,
                     session,
                     options={ 'multiple': True,
                               'types': dbus.UInt32(1) })

def on_create_rd_session_response(response, results):
    if response != 0:
        print("Failed to create session: %d"%response)
        terminate()
        return

    global session
    session = results['session_handle']
    print("session %s created"%session)

    remote_desktop_call(portal.SelectDevices, on_create_session_response,
                        session,
                        options={ 'types': dbus.UInt32(7) })

portal = bus.get_object('org.freedesktop.portal.Desktop',
                             '/org/freedesktop/portal/desktop')

(session_path, session_token) = new_session_path()
remote_desktop_call(portal.CreateSession, on_create_rd_session_response,
                 options={ 'session_handle_token': session_token })

try:
    loop.run()
except KeyboardInterrupt:
    terminate()
