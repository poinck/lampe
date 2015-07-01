using Gtk;

class Lampe : Gtk.Application {
	public Lampe() {
		Object(application_id: "com.lampe.app", flags: ApplicationFlags.FLAGS_NONE);
	}
	
	protected override void activate() {
		Gtk.ApplicationWindow lampeWindow = new Gtk.ApplicationWindow(this);
			
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
		
		// initialize soup session for bridge connection
		HueBridge bridge = new HueBridge("192.168.2.164");
			// TODO  remove hardcoded ip: this is early work, read "~/.lamperc"
		
		// initialize lights view
		Lights lights = new Lights(bridge);
		lights.refreshLights();
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
		stack.add_titled(boxingBox , "lights", "Lights");
		// stack.add_titled(groupsListBox , "groups", "Groups");
			// TODO  add groupsListBox after implementation of it has started
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
		var settingsButton = new Gtk.Button.from_icon_name (
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
			// TODO  register at bridge (seperate class)
			debug("[Lampe.activate] start: register");
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

// TODO  swap out to seperate utility class
public void hsv_to_rgb (double h, double s, double v, out double r, out double g, out double b)
		requires (h >= 0 && h <= 360)
		requires (s >= 0 && s <= 1)
		requires (v >= 0 && v <= 1) {
    // by Robert Dyer, GPLv3 or later
    r = 0; 
    g = 0; 
    b = 0;

    if (s == 0) {
        r = v;
        g = v;
        b = v;
    } else {
        var secNum = (int) Math.floor(h / 60);
        // var secNum = (int) (h / 60);
        	// removed Math.floor()
        var fracSec = h / 60.0 - secNum;

        var p = v * (1 - s);
        var q = v * (1 - s * fracSec);
        var t = v * (1 - s * (1 - fracSec));
        
        switch (secNum) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        case 5:
            r = v;
            g = p;
            b = q;
            break;
        }
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
