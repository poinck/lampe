// lampe-gtk by André Klausnitzer, CC0

using Gtk;

class Lampe : Gtk.Application {
	public Lampe() {
		Object(application_id: "net.lampe.app", flags: ApplicationFlags.FLAGS_NONE);
	}

	private void set_global_menu(ApplicationWindow window) {
		GLib.Menu global_menu = new GLib.Menu();
		global_menu.append("Info", "app.about");
		global_menu.append("Quit", "app.quit");

		GLib.SimpleAction exit_action = new GLib.SimpleAction("quit", null);
		exit_action.set_enabled(true);
		exit_action.activate.connect(() => {
			debug("[Lampe] bye");
			window.close();
		});
		this.add_action(exit_action);

		GLib.SimpleAction about_action = new GLib.SimpleAction("about", null);
		about_action.set_enabled(true);
		about_action.activate.connect(() => {
			debug("[Lampe] about");
			string license_text = get_cc0_license_text(); // see: license.vala

			string[] authors = { "André Klausnitzer", null };
			string[] documenters = { "André Klausnitzer", null };
			Gtk.show_about_dialog(
				window,
				"program-name", ("Lampe"),
				"license", ("CC0 1.0 Universal" + license_text),
				"license-type", License.CUSTOM,
				"authors", authors,
				"documenters", documenters,
				"website", "http://github.com/poinck/lampe",
				"website-label", ("github.com/poinck/lampe"),
				"logo", window.icon,
				"copyright", "by poinck, 2015",
				"version", "1.1.3",
				"comments", "Control your Hue lights.",
				null
			);
		});
		this.add_action(about_action);

		this.app_menu = global_menu;
	}

	protected override void activate() {
		// main window
		Gtk.ApplicationWindow lampeWindow = new Gtk.ApplicationWindow(this);
		lampeWindow.set_default_size(900, 600);
		lampeWindow.window_position = Gtk.WindowPosition.CENTER;
		lampeWindow.title = "Lampe";
		set_global_menu(lampeWindow);
		try {
			lampeWindow.icon = new Gdk.Pixbuf.from_file("/usr/share/pixmaps/lampe-icon.png");
		}
		catch (Error e) {
			debug("[Lampe] ERROR: could not load icon");
		}

		// header bar: add to main window
		var header = new HeaderBar();
		header.set_show_close_button(true);
		header.set_title("Lampe");
		lampeWindow.set_titlebar(header);

		// initialize soup session for bridge connection
		LampeRc rc = new LampeRc();
		string ip = rc.getBridgeIp();
		if (ip == "") {
			header.set_subtitle("no bridge");
		}
		else {
			header.set_subtitle("using bridge at " + ip);
		}
		HueBridge bridge = new HueBridge(ip);

		Grid mainGrid = new Grid();

		// box: lights
			// TODO  maybe: move everything related to the stack to a seperate method?
		Box lights_box = new Box(Orientation.VERTICAL, 8);
		Box lights_border_box = new Box(Orientation.HORIZONTAL, 8);
		Gdk.RGBA boxColor = Gdk.RGBA();
		boxColor.parse("#a4a4a4"); // grey
		lights_border_box.override_background_color(StateFlags.NORMAL, boxColor);

		Lights lights = new Lights(bridge, this); // ListBox
		lights.refresh_lights();
		// header.pack_end(lights.get_global_switch());
		lights_box.add(lights.get_header()); // Box
		lights_border_box.add(lights);
		lights_box.add(lights_border_box);

		// box: groups
		ListBox groupsListBox = new ListBox();
		groupsListBox.insert(new Label("Group A"), 1);

		// stack: add lights- and groups boxes
		var stack = new Stack();
		stack.add_titled(lights_box , "lights", "Lights");
		// stack.add_titled(groupsListBox , "groups", "Groups");
			// TODO  add groupsListBox after implementation of it has started
		stack.set_visible_child_name("lights");
		stack.homogeneous = false;
		stack.margin_start = 64;
		stack.margin_end = 64;
		stack.margin_top = 24;

		// switcher buttons for stack: add to header bar
		StackSwitcher buttons = new StackSwitcher();
		buttons.set_stack(stack);
		buttons.show();
		header.pack_start(buttons);

		// stack: add to main grid
		mainGrid.attach(stack, 0, 0, 1, 1); // first row
		mainGrid.attach(new Label(" "), 0, 1, 1, 1); // second row

		// add main grid to viewport, add viewport to scrolled window, add
		// scrolled window to main window
		Viewport view = new Viewport(null, null);
		view.add(mainGrid);
		Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow(null, null);
		scrolled.add(view);
		lampeWindow.add(scrolled);

		// button: settings
			// TODO  maybe: swap out settings-menu in a different class?
		Gtk.Button settingsButton = new Gtk.Button.from_icon_name(
			"view-list-symbolic",
			Gtk.IconSize.SMALL_TOOLBAR
		);
			// icons: preferences-other, document-properties, applications-utilities, preferences-system, start-here, applications-utilities, view-list
		GLib.Menu settingsMenu = new GLib.Menu();
		settingsMenu.append("Find new lights", "find");
		settingsMenu.append("Register at bridge", "register");
		Gtk.Popover settingsPopover = new Gtk.Popover(settingsButton);
		settingsPopover.bind_model(settingsMenu, "app");
		settingsButton.clicked.connect(() => {
			settingsPopover.set_visible(true);
		});
		GLib.SimpleAction registerAction = new GLib.SimpleAction("register", null);
		registerAction.activate.connect(() => {
			// TODO  register at bridge
			debug("[Lampe.activate] start: register");
			bridge.register(lampeWindow);
		});
		this.add_action(registerAction);
		// var popoverMenu = new Gtk.PopoverMenu ();
		// settingsButton.set_popover (popoverMenu);
			// XXX   there is no "Gtk.PopoverMenu" in 3.14?
		header.pack_end(settingsButton);

		// button: refresh
		var refreshButton = new Gtk.Button.from_icon_name(
			"view-refresh-symbolic",
			Gtk.IconSize.SMALL_TOOLBAR
		);
		refreshButton.clicked.connect(() => {
			debug("[Lampe.activate] start: refresh");
			lights.refresh_lights();
		});
		header.pack_end(refreshButton);

		header.pack_end(lights.get_global_switch());

		lampeWindow.show_all();
	}
}

public static void debug(string str) {
#if DEBUG
	if (str != null) {
		stdout.printf(str + "\n");
	}
	else {
		stdout.printf("== NULL\n");
	}
#endif
}

public static int main(string[] args) {
	debug("[main] start");

	Lampe lampe = new Lampe();
	return lampe.run(args);
}
