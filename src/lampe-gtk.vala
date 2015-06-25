using Gtk;

class Lampe : Gtk.Application {
	public Lampe() {
		Object(application_id: "com.lampe.app", flags: ApplicationFlags.FLAGS_NONE);
	}
	
	protected override void activate() {
		Gtk.ApplicationWindow lampeWindow = new Gtk.ApplicationWindow (this);
			
		var header = new HeaderBar();
		header.set_show_close_button(true);
		header.set_title("Lampe");
		header.set_subtitle("not connected");

		lampeWindow.set_default_size(1000, 700);
		lampeWindow.window_position = Gtk.WindowPosition.CENTER;
		lampeWindow.set_titlebar(header);
	
		// css
//		CssProvider css = new CssProvider();
//		var cssFile = File.new_for_path("./src/lampe-gtk.css");
//		try {
//			css.load_from_file(cssFile);
//			Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css , Gtk.STYLE_PROVIDER_PRIORITY_USER);
//		}
//		catch (Error e) {}
	
		// list box: lights
		var mainGrid = new Grid ();
		// Gtk.Alignment alignment = new Gtk.Alignment (1.0f, 1.0f, 1.0f, 1.0f);
			// XXX   depricated
		
		var boxingBox = new Box(Orientation.HORIZONTAL, 8);
//		boxingBox.hexpand = true;
//		boxingBox.margin_start = 1;
//		boxingBox.margin_end = 1;
//		boxingBox.margin_top = 1;
//		boxingBox.margin_bottom = 1;
		Gdk.RGBA boxColor = Gdk.RGBA();
		boxColor.parse("#a4a4a4"); // "#a4a4a4"
		boxingBox.override_background_color(StateFlags.NORMAL, boxColor); 
			// FIXME overrides are not recommended (a user could have loaded a 
			// theme other than Adwaita)
		
		// initialize soup session for bridge connection
		HueBridge bridge = new HueBridge("192.168.2.141");
			// TODO  remove hardcoded ip: this is early work
		
		// initialize lights view
		Lights lights = new Lights(bridge);
		
//		lights.addLight("Sofa");
//		lights.addLight("Stube");
//		lights.addLight("Schlafzimmer");
//		lights.addLight("Bad");
		
		lights.refreshLights();
		
		// test
		// lights.deleteLights();
			
		boxingBox.add(lights);
		
//		StyleContext style = new StyleContext();
//		style.add_class("lightBox");
	
		// list box: groups
		var groupsListBox = new ListBox ();
		// groupsListBox.style = style;
		groupsListBox.insert (new Label ("Group A"), 1);
//		var vBox = new Box (Orientation.HORIZONTAL, 0);
//		vBox.add (new Label ("blubber"));
//		vBox.add (new Label ("blubb"));
//		groupsListBox.insert (vBox, 2);

		// stack
		var stack = new Stack ();
		stack.add_titled (boxingBox , "lights", "Lights");
		stack.add_titled (groupsListBox , "groups", "Groups");
		stack.set_visible_child_name ("lights");
		stack.homogeneous = false;
		// stack.vexpand = false;
		// stack.expand = true;
		// stack.border_width = 1;
		stack.margin_start = 64;
		stack.margin_end = 64;
		stack.margin_top = 24;
		// lampeWindow.add (stack);
	
		// switcher
		var buttons = new StackSwitcher();
		buttons.set_stack(stack);
		buttons.show();
		header.pack_start(buttons);
		// header.set_custom_title (buttons);
		
//		mainGrid.column_homogeneous = false;
//		mainGrid.column_spacing = 8;
//		mainGrid.row_spacing = 8;
//		mainGrid.attach(new Label(" "), 0, 0, 3, 1);
//		mainGrid.attach(new Label(" "), 0, 1, 1, 1);
		mainGrid.attach(stack, 0, 0, 1, 1);
		mainGrid.attach(new Label(" "), 0, 1, 1, 1);
		
		Viewport view = new Viewport(null, null);
			// adjustment left unbound, instead of "new Adjustment(1, 1, 1, 1, 10, 10)"
		view.add(mainGrid);
		Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow(null, null);
		scrolled.add(view);
		lampeWindow.add(scrolled);
	
		// button: settings
			// TODO  swap out settings-menu in a different class?
		var settingsButton = new Gtk.Button.from_icon_name ("view-list-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
			// preferences-other, document-properties, applications-utilities, preferences-system, start-here, applications-utilities, view-list
		GLib.Menu settingsMenu = new GLib.Menu ();
		settingsMenu.append("Find new lights", "find");
		settingsMenu.append("Register at bridge", "register");
		Gtk.Popover settingsPopover = new Gtk.Popover(settingsButton);
		settingsPopover.bind_model(settingsMenu, "app");
		settingsButton.clicked.connect(() => {
			settingsPopover.set_visible(true);
		});
		GLib.SimpleAction registerAction = new GLib.SimpleAction("register", null);
		registerAction.activate.connect(() => {
			// TODO  register at bridge (seperate class)
			stdout.printf ("[Lampe.activate] start: register\n");
		});
		this.add_action(registerAction);
		// var popoverMenu = new Gtk.PopoverMenu ();
		// settingsButton.set_popover (popoverMenu);
			// XXX   there is no "Gtk.PopoverMenu" in 3.14?	
		header.pack_end(settingsButton);
		
		// button: refresh
		var refreshButton = new Gtk.Button.from_icon_name("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		refreshButton.clicked.connect(() => {
			// debug
			stdout.printf("[Lampe.activate] start: refresh\n");
			
			lights.refreshLights();
		});
//		GLib.SimpleAction refreshAction = new GLib.SimpleAction("refresh", null);
//		refreshAction.activate.connect(() => {
//			// TODO  refresh light states (seperate class, pointer to titled stack)
//			stdout.printf("[Lampe.activate] START refresh\n");
//		});
//		this.add_action(refreshAction);
		header.pack_end(refreshButton);
		
		lampeWindow.show_all();
	}
}

public static int main(string[] args) {
	// debug
	stdout.printf("[main] start\n");
	
	Lampe lampe = new Lampe();	
	return lampe.run(args);
}
