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

public errordomain CommandError {
    EMPTY_COMMAND,
    INVALID_COMMAND,
    INVALID_ARG,
    NOT_CONNECTED
}

abstract class Command : Object {
    protected OptionContext context;
    protected string[] args;

    public abstract bool run () throws Error;
    public virtual OptionEntry[]? get_options () {
        return null;
    }

    public void parse_commandline (string[] args) throws Error {
        if (this.get_options () != null) {
            this.context = new OptionContext ("");
            this.context.set_help_enabled (false);
            this.context.set_ignore_unknown_options (true);
            this.context.add_main_entries (this.get_options (), null);
            this.context.parse (ref args);
        }
    }

    public static Command parse (string input) throws Error {
        Command command;
        string[] commandline;
        Shell.parse_argv (input, out commandline);

        switch (commandline[0].down ()) {
            case "ls":
            case "browse":
                command = new BrowseCommand ();
                break;
            case "connect":
                command = new ConnectCommand ();
                break;
            case "list":
                command = new ListCommand ();
                break;
            case "cd":
                command = new CdCommand ();
                break;
            case "info":
                command = new InfoCommand ();
                break;
            case "disconnect":
                command = new DisconnectCommand ();
                break;
            default:
                throw new CommandError.INVALID_COMMAND
                                        ("No such command: %s. Use \"help\"" +
                                         " to get a list of possible commands.",
                                         commandline[0]);
        }

        command.parse_commandline (commandline);
        command.args = commandline;
        return command;
    }
}
