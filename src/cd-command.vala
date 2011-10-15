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

class CdCommand : Command {
    public override bool run () throws Error {
        if (args.length == 1) {
            path.clear ();

            return true;
        }

        if (args[1] == "..") {
            path.up ();

            return true;
        }

        if (args[1] == ".") {
            return true;
        }

        if (current_device == null) {
            throw new CommandError.NOT_CONNECTED
                ("Not connected to any device. Please use \"connect\"");
        }

        var service = current_device.get_service
                                        (DeviceLister.CONTENT_DIRECTORY);
        var content_directory = new ContentDirectory
                                        (service as ServiceProxy);


        try {
            var result = content_directory.browse
                                        (args[1],
                                         ContentDirectory.BROWSE_META_DATA);

            var parser = new DIDLLiteParser ();
            parser.object_available.connect ( (o) => {
                if ((path.top () == null && o.parent_id == "0") ||
                    (path.top () == o.parent_id)) {
                    path.cd (args[1]);
                } else {
                    print ("1) No such child: %s", path.top ());
                }
            });
            if (result != null && result != "") {
                parser.parse_didl (result);
            } else {
                print ("2) No such child: %s", path.top ());
            }
        } catch (Error error) {
            debug ("==>%s", error.message);
        }

        return true;
    }

    public override void help () {
    }
}
