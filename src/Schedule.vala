// lampe-gtk by André Klausnitzer, CC0

using Gtk;

public class Schedule : Box {
	private int light_id;
	private int schedule_id;
	private string schedule_name = "Alarm";
	private string time;
	private int64 bri = 192;
	private int64 sat = 254;
	private string status = "enabled";

	// private Gtk.Application app;
	private HueBridge bridge;

	private Gtk.Popover schedule_popover;
	private GLib.Menu schedule_menu;
	private Label name_label;
	private Label time_label;
	private Image menu_img;

	public Schedule(int schedule_id, string name, int light_id, string time,
			int64 bri = 192, int64 sat = 254, string status = "enabled",
			Gtk.Application app, HueBridge bridge) {
		this.schedule_id = schedule_id;
		this.schedule_name = name;
		this.light_id = light_id;
		this.time = time;
		this.bri = bri;
		this.sat = sat;
		this.status = status;

		this.orientation = Orientation.HORIZONTAL;
		this.spacing = 8;
		this.margin_start = 94;

		this.bridge = bridge;

		/*
		Image clock_img = new Image.from_icon_name("alarm-symbolic", IconSize.MENU);
			// IconSize.INVALID
		this.add(clock_img);
		*/

		// name
		name_label = new Label("<b>" + schedule_name + "</b>");
		name_label.use_markup = true;
		this.add(name_label);

		// time
		time_label = new Label(time);
		time_label.use_markup = true;
		this.add(time_label);

		// popover: schedule_menu
		menu_img = new Image.from_icon_name("pan-down-symbolic", IconSize.MENU);
		this.add(menu_img);
		schedule_menu = new GLib.Menu();
		update_widgets(); // adds "Enable" or "Disable" menu entry
		GLib.SimpleAction enable_disable_action = new GLib.SimpleAction(
			"enable_disable_" + schedule_id.to_string(),
			null
		);
		enable_disable_action.activate.connect(() => {
			debug("[Schedule] enable_disable_action.activate, schedule_id = "
				+ schedule_id.to_string());
			toggle_schedule();
		});
		app.add_action(enable_disable_action);

		schedule_menu.append("Edit", "edit");
		schedule_menu.append("Delete", "delete");

		schedule_popover = new Gtk.Popover(menu_img);
		schedule_popover.bind_model(schedule_menu, "app");

	}

	// updates Schedule's widgets and it's popover based on "status"
	private void update_widgets() {
		if (schedule_menu.get_n_items() > 0) {
			schedule_menu.remove(0);
		}
		if (status == "disabled") {
			name_label.opacity = 0.4;
			time_label.opacity = 0.4;
			menu_img.opacity = 0.4;
			schedule_menu.prepend(
				"Enable",
				"enable_disable_" + schedule_id.to_string()
			);
		}
		else {
			name_label.opacity = 1;
			time_label.opacity = 1;
			menu_img.opacity = 1;
			schedule_menu.prepend(
				"Disable",
				"enable_disable_" + schedule_id.to_string()
			);
		}
		debug("[Schedule.update_widgets] status = " + status);
	}

	// callback from HueBridge after put_schedule_state()
	public void schedule_state_changed(string rsp) {
		// TODO  check wether rsp is "success", "error" or nothing?
		update_widgets();
	}

	// show Schedule's popover
	public void show_schedule_menu() {
		debug("[Schedule.show_schedule_menu] schedule_id = "
			+ schedule_id.to_string());
		schedule_popover.set_visible(true);
	}

	// toggle "status" of schedule
	private void toggle_schedule() {
		if (this.status == "enabled") {
			this.status = "disabled";
		}
		else {
			this.status = "enabled";
		}
		bridge.put_schedule_state(this, "{\"status\": \"" + this.status + "\"}");
	}

	public int get_light_id() {
		return this.light_id;
	}

	public int get_schedule_id() {
		return this.schedule_id;
	}
}
