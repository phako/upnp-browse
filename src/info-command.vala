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

class InfoCommand : Command {
    private bool show_raw_didle = false;

    void dump_container_information (DIDLLiteContainer container) {
        print ("Meta-data for %s\n", container.id);
        print ("  UPnP class: %s\n", container.upnp_class);
        print ("  Parent:     %s\n", container.parent_id);
        print ("  Children:   %d\n", container.child_count);
        print ("  Searchable: %s\n", container.searchable.to_string ());

        print ("  Resources:\n");
        print ("  ----------\n");

        foreach (var res in container.get_resources ()) {
            print ("    Uri: %s\n", res.uri);
            if (res.size64 != -1)
                print ("      Size: %s",
                       format_size (res.size64, FormatSizeFlags.LONG_FORMAT));

            if (res.protocol_info != null) {
                print ("      DLNA protocol info: %s\n",
                       res.protocol_info.to_string ());
            }

            print ("\n");
        }

    }

    void dump_item_information (DIDLLiteItem item) {
        print ("Meta-data for %s\n", item.id);
        print ("  UPnP class: %s\n", item.upnp_class);
        print ("  Parent:     %s\n", item.parent_id);
        if (item.ref_id != null) {
            print ("  References: %s\n", item.ref_id);
        }

        print ("  Resources:\n");
        print ("  ----------\n");

        foreach (var res in item.get_resources ()) {
            print ("    Uri: %s\n", res.uri);
            if (res.size64 != -1)
                print ("      Size: %s",
                       format_size (res.size64, FormatSizeFlags.LONG_FORMAT));

            if (res.protocol_info != null) {
                print ("      DLNA protocol info: %s\n",
                       res.protocol_info.to_string ());
            }

            print ("\n");
        }
    }

    public override bool run () throws Error {
        if (current_device == null) {
            throw new CommandError.NOT_CONNECTED
                ("Not connected to any device. Please use \"connect\"");
        }

        var service = current_device.get_service
                                        (DeviceLister.CONTENT_DIRECTORY);
        var content_directory = new ContentDirectory
                                        (service as ServiceProxy);

        var result = content_directory.browse (this.args[1],
                                               ContentDirectory.BROWSE_META_DATA,
                                               "*",
                                               0,
                                               0);
        if (this.show_raw_didle) {
            print ("%s\n", result);
        } else {
            var parser = new DIDLLiteParser ();
            parser.container_available.connect ( (c) => {
                this.dump_container_information (c);
            });

            parser.item_available.connect ( (i) => {
                this.dump_item_information (i);
            });

            parser.parse_didl (result);
        }

        return true;
    }

    public override OptionEntry[]? get_options () {
        OptionEntry[] options = new OptionEntry[2];
        options[0] = { "raw",
                       'r',
                       0,
                       OptionArg.NONE,
                       ref this.show_raw_didle,
                       "Do not parse DIDL",
                       null };

        options[1] = { null };

        return options;
    }

    public override void help () {
    }
}
