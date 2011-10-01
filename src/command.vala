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

class HelpCommand : Command {
    public unowned HashTable<string, Type?> registry;

    public override bool run () throws Error {
        if (this.args.length == 1) {
            print ("Available commands:\n");
            foreach (var command in this.registry.get_keys ()) {
                print ("%s\n", command);
            }
            print ("Use help <command> to get help for a specific command\n");
        }

        return true;
    }
}

namespace CommandFactory {
    private static HashTable<string, Type> command_registry;

    internal static Command parse (string input) throws Error {
        if (CommandFactory.command_registry == null) {
            CommandFactory.command_registry =
                new HashTable<string, Type?> (str_hash, str_equal);

            command_registry.insert ("browse",     typeof (BrowseCommand));
            command_registry.insert ("cd",         typeof (CdCommand));
            command_registry.insert ("connect",    typeof (ConnectCommand));
            command_registry.insert ("disconnect", typeof (DisconnectCommand));
            command_registry.insert ("help",       typeof (HelpCommand));
            command_registry.insert ("info",       typeof (InfoCommand));
            command_registry.insert ("list",       typeof (ListCommand));
            command_registry.insert ("ls",         typeof (BrowseCommand));
            command_registry.insert ("?",          typeof (HelpCommand));
        }

        Command command;
        string[] commandline;
        Shell.parse_argv (input, out commandline);
        Type type;

        if (!CommandFactory.command_registry.lookup_extended (commandline[0].down (),
                                                              null,
                                                              out type)) {
            throw new CommandError.INVALID_COMMAND
                ("No such command: %s. Use \"help\" to get a list of " +
                 "possible commands.",
                 commandline[0]);
        }

        command = Object.new (type) as Command;
        command.parse_commandline (commandline);
        if (command is HelpCommand) {
            (command as HelpCommand).registry =
                CommandFactory.command_registry;
        }

        return command;
    }
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
        this.args = args;
    }
}
