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

class BrowsePath : Object {
    private List<string> stack;
    private string path;
    private bool dirty;

    public BrowsePath () {
        this.stack = new List<string> ();
        this.dirty = true;
    }

    public void up () {
        this.stack.remove_link (this.stack);
        this.dirty = true;
    }

    public void cd (string sibling) {
        this.stack.prepend (sibling);
        this.dirty = true;
    }

    public void clear () {
        this.stack = new List<string> ();
        this.dirty = true;
    }

    public string? top () {
        if (this.stack != null) {
            return this.stack.data;
        }

        return null;
    }

    public string to_string () {
        if (this.dirty) {
            var path = new StringBuilder ("/");
            foreach (var item in this.stack) {
                path.prepend (item);
                path.prepend ("/");
            }

            this.path = path.str;
            this.dirty = false;
        }

        return this.path;
    }
}


