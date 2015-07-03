// lampe-gtk by André Klausnitzer, CC0

using Gtk;

class Lampe : Gtk.Application {
	public Lampe() {
		Object(application_id: "net.lampe.app", flags: ApplicationFlags.FLAGS_NONE);
	}
	
	private void set_global_menu(ApplicationWindow window) {
		GLib.Menu global_menu = new GLib.Menu();
		global_menu.append("Info", "info");
		global_menu.append("Exit", "exit");
		
		GLib.SimpleAction exit_action = new GLib.SimpleAction("exit", null);
		exit_action.set_enabled(true);
		exit_action.activate.connect(() => {
			debug("[Lampe] bye");
			window.close();
		});
		this.add_action(exit_action);
		
		this.app_menu = global_menu;
	}
	
	protected override void activate() {
		// main window
		Gtk.ApplicationWindow lampeWindow = new Gtk.ApplicationWindow(this);
		lampeWindow.set_default_size(1000, 700);
		lampeWindow.window_position = Gtk.WindowPosition.CENTER;
		lampeWindow.title = "Lampe";
		// set_global_menu(lampeWindow);
			// FIXME set_global_menu(..): menu entries are disabled, not sure why.
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
	
		// css
//		CssProvider css = new CssProvider();
//		var cssFile = File.new_for_path("./src/lampe-gtk.css");
//		try {
//			css.load_from_file(cssFile);
//			Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css , Gtk.STYLE_PROVIDER_PRIORITY_USER);
//		}
//		catch (Error e) {}
	
		Grid mainGrid = new Grid();
	
		// box: lights
			// TODO  maybe: move everything related to the stack to a seperate method?
		Box lights_box = new Box(Orientation.VERTICAL, 8);
		Box lights_border_box = new Box(Orientation.HORIZONTAL, 8);
		Gdk.RGBA boxColor = Gdk.RGBA();
		boxColor.parse("#a4a4a4"); // grey
		lights_border_box.override_background_color(StateFlags.NORMAL, boxColor); 
		
		Lights lights = new Lights(bridge); // ListBox
		lights.refresh_lights();
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
