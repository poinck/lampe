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
			
			string license_text = "\n\nStatement of Purpose

The laws of most jurisdictions throughout the world automatically confer
exclusive Copyright and Related Rights (defined below) upon the creator and
subsequent owner(s) (each and all, an \"owner\") of an original work of
authorship and/or a database (each, a \"Work\").

Certain owners wish to permanently relinquish those rights to a Work for the
purpose of contributing to a commons of creative, cultural and scientific
works (\"Commons\") that the public can reliably and without fear of later
claims of infringement build upon, modify, incorporate in other works, reuse
and redistribute as freely as possible in any form whatsoever and for any
purposes, including without limitation commercial purposes. These owners may
contribute to the Commons to promote the ideal of a free culture and the
further production of creative, cultural and scientific works, or to gain
reputation or greater distribution for their Work in part through the use and
efforts of others.

For these and/or other purposes and motivations, and without any expectation
of additional consideration or compensation, the person associating CC0 with a
Work (the \"Affirmer\"), to the extent that he or she is an owner of Copyright
and Related Rights in the Work, voluntarily elects to apply CC0 to the Work
and publicly distribute the Work under its terms, with knowledge of his or her
Copyright and Related Rights in the Work and the meaning and intended legal
effect of CC0 on those rights.

1. Copyright and Related Rights. A Work made available under CC0 may be
protected by copyright and related or neighboring rights (\"Copyright and
Related Rights\"). Copyright and Related Rights include, but are not limited
to, the following:

  i. the right to reproduce, adapt, distribute, perform, display, communicate,
  and translate a Work;

  ii. moral rights retained by the original author(s) and/or performer(s);

  iii. publicity and privacy rights pertaining to a person's image or likeness
  depicted in a Work;

  iv. rights protecting against unfair competition in regards to a Work,
  subject to the limitations in paragraph 4(a), below;

  v. rights protecting the extraction, dissemination, use and reuse of data in
  a Work;

  vi. database rights (such as those arising under Directive 96/9/EC of the
  European Parliament and of the Council of 11 March 1996 on the legal
  protection of databases, and under any national implementation thereof,
  including any amended or successor version of such directive); and

  vii. other similar, equivalent or corresponding rights throughout the world
  based on applicable law or treaty, and any national implementations thereof.

2. Waiver. To the greatest extent permitted by, but not in contravention of,
applicable law, Affirmer hereby overtly, fully, permanently, irrevocably and
unconditionally waives, abandons, and surrenders all of Affirmer's Copyright
and Related Rights and associated claims and causes of action, whether now
known or unknown (including existing as well as future claims and causes of
action), in the Work (i) in all territories worldwide, (ii) for the maximum
duration provided by applicable law or treaty (including future time
extensions), (iii) in any current or future medium and for any number of
copies, and (iv) for any purpose whatsoever, including without limitation
commercial, advertising or promotional purposes (the \"Waiver\"). Affirmer makes
the Waiver for the benefit of each member of the public at large and to the
detriment of Affirmer's heirs and successors, fully intending that such Waiver
shall not be subject to revocation, rescission, cancellation, termination, or
any other legal or equitable action to disrupt the quiet enjoyment of the Work
by the public as contemplated by Affirmer's express Statement of Purpose.

3. Public License Fallback. Should any part of the Waiver for any reason be
judged legally invalid or ineffective under applicable law, then the Waiver
shall be preserved to the maximum extent permitted taking into account
Affirmer's express Statement of Purpose. In addition, to the extent the Waiver
is so judged Affirmer hereby grants to each affected person a royalty-free,
non transferable, non sublicensable, non exclusive, irrevocable and
unconditional license to exercise Affirmer's Copyright and Related Rights in
the Work (i) in all territories worldwide, (ii) for the maximum duration
provided by applicable law or treaty (including future time extensions), (iii)
in any current or future medium and for any number of copies, and (iv) for any
purpose whatsoever, including without limitation commercial, advertising or
promotional purposes (the \"License\"). The License shall be deemed effective as
of the date CC0 was applied by Affirmer to the Work. Should any part of the
License for any reason be judged legally invalid or ineffective under
applicable law, such partial invalidity or ineffectiveness shall not
invalidate the remainder of the License, and in such case Affirmer hereby
affirms that he or she will not (i) exercise any of his or her remaining
Copyright and Related Rights in the Work or (ii) assert any associated claims
and causes of action with respect to the Work, in either case contrary to
Affirmer's express Statement of Purpose.

4. Limitations and Disclaimers.

  a. No trademark or patent rights held by Affirmer are waived, abandoned,
  surrendered, licensed or otherwise affected by this document.

  b. Affirmer offers the Work as-is and makes no representations or warranties
  of any kind concerning the Work, express, implied, statutory or otherwise,
  including without limitation warranties of title, merchantability, fitness
  for a particular purpose, non infringement, or the absence of latent or
  other defects, accuracy, or the present or absence of errors, whether or not
  discoverable, all to the greatest extent permissible under applicable law.

  c. Affirmer disclaims responsibility for clearing rights of other persons
  that may apply to the Work or any use thereof, including without limitation
  any person's Copyright and Related Rights in the Work. Further, Affirmer
  disclaims responsibility for obtaining any necessary consents, permissions
  or other rights required for any use of the Work.

  d. Affirmer understands and acknowledges that Creative Commons is not a
  party to this document and has no duty or obligation with respect to this
  CC0 or use of the Work.

For more information, please see: 
http://creativecommons.org/publicdomain/zero/1.0";
			
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
				"version", "1.1.2",
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
		lampeWindow.set_default_size(1000, 700);
		lampeWindow.window_position = Gtk.WindowPosition.CENTER;
		lampeWindow.title = "Lampe";
		set_global_menu(lampeWindow);
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
