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

DeviceLister lister;
DeviceProxy current_device;
BrowsePath path;

class Main : Object {
    private string prompt;
    private IOChannel input_channel;
    private MainLoop loop;

    public static Main instance;

    private static void readline_callback (string? s) {
        instance.run_command (s);
    }

    public static Main get_instance () {
        if (instance == null) {
            instance = new Main ();
        }

        return instance;
    }

    private Main () {
        lister = new DeviceLister ();
        path = new BrowsePath ();
        this.update_prompt ();
    }

    public void run () {
        unowned string data_dir = Environment.get_user_data_dir ();
        var cache_dir = Path.build_filename (data_dir, "upnp-browse");
        var cache_file = Path.build_filename (cache_dir, "history");

        Readline.readline_name = "upnp-browse";

        DirUtils.create_with_parents (cache_dir, 0700);

        Readline.History.read (cache_file);

        this.input_channel = new IOChannel.unix_new (stdin.fileno ());
        Readline.callback_handler_install (this.prompt,
                                           Main.readline_callback);

        this.input_channel.add_watch (IOCondition.IN |
                                      IOCondition.PRI,
                                      () => {
            Readline.callback_read_char ();

            return true;
        });

        this.loop = new MainLoop ();
        this.loop.run ();
        Readline.History.write (cache_file);
    }

    void update_prompt () {
        if (current_device != null) {
            this.prompt = current_device.get_friendly_name ();
        } else {
            this.prompt = "";
        }
        this.prompt += ":" + path.to_string () + "> ";
        Readline.set_prompt (this.prompt);
    }

    void run_command (string? input) {
        if (input == null ||
            this.is_quit_command (input)) {
            Readline.callback_handler_remove ();
            loop.quit ();

            return;
        }

        if (input == "") {
            return;
        }

        Readline.History.add (input);

        try {
            var command = CommandFactory.parse (input);
            command.run ();
            this.update_prompt ();
        } catch (Error error) {
            print ("%s\n", error.message);
        }
    }

    private bool is_quit_command (string command) {
        return command == "q" ||
               command == "quit" ||
               command == "bye";
    }

}

int main (string[] args) {
    var runner = Main.get_instance ();
    runner.run ();

    return 0;
}
