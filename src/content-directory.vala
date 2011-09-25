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

public class ContentDirectory : Object {
    public const string BROWSE_DIRECT_CHILDREN = "BrowseDirectChildren";
    public const string BROWSE_META_DATA       = "BrowseMetadata";

    private ServiceProxy proxy;

    public ContentDirectory (ServiceProxy proxy) {
        this.proxy = proxy;
    }

    public string browse (string   id     = "0",
                          string   flag   = BROWSE_DIRECT_CHILDREN,
                          string   filter = "dc:title",
                          uint     start  = 0,
                          uint     limit  = 0,
                          string   sort_criteria = "+dc:title",
                          out uint returned = null,
                          out uint total = null) throws Error {
        string result = null;
        uint inner_returned;
        uint inner_total;

        this.proxy.send_action (
                          "Browse",
                          "ObjectID", typeof (string), id,
                          "BrowseFlag", typeof (string), flag,
                          "Filter", typeof (string), filter,
                          "StartingIndex", typeof (uint), start,
                          "RequestedCount", typeof (uint), limit,
                          "SortCriteria", typeof (string), sort_criteria,
                          null,
                          "Result", typeof (string), out result,
                          "NumberReturned", typeof (uint), out inner_returned,
                          "TotalMatches", typeof (uint), out inner_total,
                          null);
        returned = inner_returned;
        total = inner_total;

        return result;
    }
}
