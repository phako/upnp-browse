/*
    This file is part of upnp-browse.

    upnp-browse is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    upnp-browse is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with upnp-browse.  If not, see <http://www.gnu.org/licenses/>.
*/

using GUPnP;

internal class DeviceLister : Object {
    private ContextManager context_manager;
    private HashTable<string, DeviceProxy> device_set;

    private const string MEDIA_SERVER_V1 =
        "urn:schemas-upnp-org:device:MediaServer:1";
    public const string CONTENT_DIRECTORY =
        "urn:schemas-upnp-org:service:ContentDirectory";

    public DeviceLister () {
        this.device_set = new HashTable<string, DeviceProxy> (str_hash,
                                                              str_equal);
        this.context_manager = ContextManager.create (0);

        this.context_manager.context_available.connect
                                        (this.on_context_available);
        this.context_manager.context_unavailable.connect
                                        (this.on_context_unavailable);
    }

    public unowned DeviceProxy? get_device (string udn) {
        return this.device_set.lookup (udn);
    }

    public unowned DeviceProxy? get_device_by_friendly_name
                                        (string friendly_name) {
        foreach (var device in this.devices ()) {
            if (device.get_friendly_name () == friendly_name) {
                return device;
            }
        }

        return null;
    }

    public List<unowned DeviceProxy> devices () {
        return this.device_set.get_values ();
    }

    private void on_context_available (ContextManager context_manager,
                                       Context        context) {
        var control_point = new ControlPoint (context, MEDIA_SERVER_V1);
        control_point.device_proxy_available.connect
                                        (this.on_device_proxy_available);

        control_point.device_proxy_unavailable.connect
                                        (this.on_device_proxy_unavailable);

        control_point.active = true;

        context_manager.manage_control_point (control_point);
    }

    private void on_context_unavailable (ContextManager context_manager,
                                         Context        context) {
    }

    private void on_device_proxy_available (ControlPoint control_point,
                                            DeviceProxy  media_server) {
        var content_directory = media_server.get_service (CONTENT_DIRECTORY);
        if (content_directory != null)
            this.device_set.insert (media_server.udn, media_server);
    }

    private void on_device_proxy_unavailable (ControlPoint control_point,
                                              DeviceProxy  media_server) {
        this.device_set.remove (media_server.udn);
    }

}
