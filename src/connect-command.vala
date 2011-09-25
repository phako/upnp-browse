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

class ConnectCommand : Command {

    public override bool run () throws Error {
        if (args.length < 2) {
            throw new CommandError.INVALID_ARG ("Target missing.");
        }

        if (args.length > 2) {
            throw new CommandError.INVALID_ARG ("Only one target allowed");
        }

        if (args[1].has_prefix ("uuid:")) {
            current_device = lister.get_device (args[1]);
        } else {
            current_device = lister.get_device_by_friendly_name (args[1]);
        }

        return true;
    }
}
