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

class BrowseCommand : Command {
    static string _container = null;
    static string _sort_criteria = "+upnp:class,+dc:title";

    const OptionEntry[] _options = {
        { "container", 'c', 0, OptionArg.STRING, ref _container, "ID of the container to browse", "ID" },
        { "sort-criteria", 's', 0, OptionArg.STRING, ref _sort_criteria, "sort order of the result", "SORT-ORDER" },
        { null }
    };

    public override bool run () throws Error {
        if (current_device == null) {
            throw new CommandError.NOT_CONNECTED
                ("Not connected to any device. Please use \"connect\"");
        }

        var service = current_device.get_service
                                        (DeviceLister.CONTENT_DIRECTORY);
        var content_directory = new ContentDirectory
                                        (service as ServiceProxy);

        uint returned = 0;
        uint total = 0;
        var start = 0;
        var requested = 0;
        var filter = "upnp:class,dc:title,res@size";

        if (_container == null) {
            _container = path.top ();
            if (_container == null) {
                _container = "0";
            }
        }

        var result = content_directory.browse (_container,
                                               ContentDirectory.BROWSE_DIRECT_CHILDREN,
                                               filter,
                                               start,
                                               requested,
                                               _sort_criteria,
                                               out returned,
                                               out total);

        var parser = new DIDLLiteParser ();
        parser.object_available.connect ( (o) => {
            print ("%s\t%s\n", o.id, o.title);
        });
        parser.parse_didl (result);
        print ("%u of %u results.\n", returned, total);

        _container = null;
        _sort_criteria = "+upnp:class,+dc:title";

        return true;
    }

    public override OptionEntry[]? options () {
        return _options;
    }
}
