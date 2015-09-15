// lampe-gtk by André Klausnitzer, CC0

using Gtk;

public class Light : Box {
	public static const double MAX_HUE = 65535.0;

	private int number;
	private double hue; // range 1..360
	private bool dont_change_bri = false;
	private bool dont_change_sat = false;
	private bool dont_change_switch = false;
	private HueBridge bridge;
	private Lights lights;

	private Switch lightSwitch;
	private Scale scaleBri;
	private Scale scaleSat;
	// private Box schedule_box = new Box(Orientation.VERTICAL, 2);

	private CssProvider css;

	// private List<Schedule> schedules = new List<Schedule>();
		// depricated

	// initialize a Box for a light
	public Light(int number, string name, int64 hue, int64 sat, int64 bri,
			bool lswitch, bool reachable, HueBridge bridge, Lights lights) {
		this.spacing = 16;
		this.margin_top = 8;
		this.margin_bottom = 8;
		this.border_width = 0;
		this.valign = Align.END;

		this.number = number;
		this.bridge = bridge;
		this.lights = lights;

		// css
		css = new CssProvider();
		Gtk.StyleContext.add_provider_for_screen(
			(!)Gdk.Screen.get_default(),
			css,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);

		// saturation
		scaleSat = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleSat.get_style_context().add_class("scale" + this.number.to_string());

		// brightness
		scaleBri = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);

		// hue
		Gtk.Button lightHue = new Gtk.Button.from_icon_name(
			"dialog-information-symbolic",
			Gtk.IconSize.SMALL_TOOLBAR
		);
		Gdk.RGBA color = Gdk.RGBA();
		double h = hue / MAX_HUE * 360.0;
		this.hue = h;
		double s = sat / 255.0;
		double v = 0.8; // drop actual representation of brightness
		double r, g, b;
		hsv_to_rgb(h, s, v, out r, out g, out b);
		color.red = r;
		color.green = g;
		color.blue = b;
		color.alpha = 1;
		debug("h = " + h.to_string() + ", s = " + s.to_string() + ", v = "
			+ v.to_string());
		debug("r = " + r.to_string() + ", g = " + g.to_string() + ", b = "
			+ b.to_string());
		lightHue.override_color(StateFlags.NORMAL, color);
		lightHue.relief = ReliefStyle.NONE;
		lightHue.clicked.connect(() => {
			// open color chooser dialog
			Gtk.ColorChooserDialog dialog = new Gtk.ColorChooserDialog(
				"Select a color",
				(Gtk.Window) this.get_toplevel()
			);
			dialog.modal = true;
			dialog.use_alpha = false;
			dialog.show();

			if (dialog.run() == Gtk.ResponseType.OK) {
				r = dialog.rgba.red;
				g = dialog.rgba.green;
				b = dialog.rgba.blue;
				rgb_to_hsv(r, g, b, out h, out s, out v);
				h = h * 360.0; // range of h was 0..1
				debug("[Light." + this.number.to_string()
					+ "] selected color: r = " + r.to_string() + ", g = "
					+ g.to_string() + ", b = " + b.to_string());
				debug("[Light." + this.number.to_string()
					+ "] selected color: h = " + h.to_string() + ", s = "
					+ s.to_string() + ", v = " + v.to_string());
				this.hue = h; // this.hue needs to have a range of 1..360
				int tmpBri = (int) (v * 255);
				int tmpSat = (int) (s * 255);
				bridge.put_light_state(
					this.number,
					"{\"bri\":" + tmpBri.to_string() + ",\"sat\": "
						+ tmpSat.to_string() + ",\"hue\": "
						+ getHue().to_string() + "}"
				);

				// update widgets
				debug("[Light." + this.number.to_string()
					+ "(hue)] this.hue = " + this.hue.to_string());
				dont_change_sat = true;
				dont_change_bri = true;
					// avoid sending brightness and saturation again
				scaleBri.set_value(v * 255);
				scaleSat.set_value(s * 255);
				v = 0.8;
				hsv_to_rgb(h, s, v, out r, out g, out b);
				color.red = r;
				color.green = g;
				color.blue = b;
				lightHue.override_color(StateFlags.NORMAL, color);

				// update css
				update_css(r, g, b);
			}
			dialog.close();
		});
		this.pack_start(lightHue, false, false, 8);

		// number (light id)
		Label lightNumber = new Label("<b>" + number.to_string() + "</b>");
		lightNumber.use_markup = true;
		lightNumber.valign = Align.BASELINE;
		this.pack_start(lightNumber, false, false, 0);

		// name
		debug("[Light] name = " + name);
		Label lightName = new Label(name);
		lightName.valign = Align.BASELINE;
		this.pack_start(lightName, false, false, 4);

		Label emptyLabel = new Label(" ");
		this.pack_start(emptyLabel, true, false, 0);

		// switch: on, off
		lightSwitch = new Switch();
		lightSwitch.get_style_context().add_class("switch" + this.number.to_string());
		lightSwitch.active = lswitch;
		if (reachable == false) {
			lightSwitch.opacity = 0.4;
			lightSwitch.tooltip_text = "not reachable";
		}
		lightSwitch.margin_bottom = 4;
		lightSwitch.valign = Align.END;

		// saturation
		scaleSat.set_value((double) sat);
		scaleSat.draw_value = false;
		scaleSat.width_request = 127;
		scaleSat.round_digits = 0;
		scaleSat.margin_bottom = 4;
		scaleSat.valign = Align.END;
		this.pack_start(scaleSat, false, false, 0);
		scaleSat.value_changed.connect(() => {
			if (lightSwitch.active) {
				debug("[Light." + this.number.to_string() + "] sat = "
					+ getSat().to_string());
				if (dont_change_sat == false) {
					// avoid sending same saturation again
					bridge.put_light_state(
						this.number,
						"{\"sat\": " + getSat().to_string() + "}"
					);
				}
				else {
					dont_change_sat = false;
				}
			}

			// update widgets
			debug("[Light." + this.number.to_string()
				+ "(saturation)] this.hue = " + this.hue.to_string());
			h = this.hue;
			s = getSat() / 255.0;
			v = 0.8;
			hsv_to_rgb(h, s, v, out r, out g, out b);
			color.red = r;
			color.green = g;
			color.blue = b;
			color.alpha = 1;
			debug("[Light." + this.number.to_string()
				+ "] changed saturation: h = " + h.to_string()
				+ ", s = " + s.to_string() + ", v = " + v.to_string());
			debug("[Light." + this.number.to_string()
				+ "] changed saturation: r = " + r.to_string()
				+ ", g = " + g.to_string() + ", b = " + b.to_string());
			lightHue.override_color(StateFlags.NORMAL, color);

			// update css
			update_css(r, g, b);
		});

		// brightness
		scaleBri.set_value((double) bri);
		scaleBri.draw_value = false;
		scaleBri.width_request = 127; // 254
		scaleBri.round_digits = 0;
		scaleBri.opacity = 0.25 + (0.75 * scaleBri.get_value() / 254);
		scaleBri.margin_bottom = 4;
		scaleBri.valign = Align.END;
		this.pack_start(scaleBri, false, false, 0);
		scaleBri.value_changed.connect(() => {
			if (lightSwitch.active) {
				debug("[Light." + this.number.to_string() + "] bri = "
					+ getBri().to_string());
				if (dont_change_bri == false) {
					// avoid sending same brightness again
					bridge.put_light_state(
						this.number,
						"{\"bri\": " + getBri().to_string() + "}"
					);
				}
				else {
					dont_change_bri = false;
				}
			}

			// update widgets
			debug("[Light." + this.number.to_string() + "] changed brightness");
			scaleBri.opacity = 0.25 + (0.75 * scaleBri.get_value() / 254);
		});

		// switch: on, off
		lightSwitch.margin_start = 10;
		this.pack_start(lightSwitch, false, false, 0);
		lightSwitch.notify["active"].connect(() => {
			toggle_switch();
			update_css(r, g, b);
		});

		// button: plus (add new schedules/alarms and ..)
			// TODO  find suitable symbolic icon for "plus"-button; names "new"
			// and "plus" don't exist
		Gtk.Button plus_button = new Gtk.Button.from_icon_name(
			"list-add-symbolic",
			Gtk.IconSize.SMALL_TOOLBAR
		);
		plus_button.relief = ReliefStyle.NONE;
		plus_button.margin_start = 0;
		plus_button.margin_end = 8;
		this.pack_start(plus_button, false, false, 0);
		plus_button.clicked.connect(() => {
			debug("[Light] plus_button clicked");
				// TODO  open "plus"-popover
		});

		// initial update of css
		update_css(r, g, b);
	}

	private int getBri() {
		return (int) scaleBri.get_value();
	}

	private int getSat() {
		return (int) scaleSat.get_value();
	}

	private int getHue() {
		return (int) (this.hue / 360.0 * MAX_HUE);
	}

	private void toggle_switch() {
		if (dont_change_switch == false) {
			// do not send new individual light switch states if global switch
			// was used
			if (lightSwitch.active) {
				// send all light attributes to bridge
				debug("[Light.toggleSwitch] switch " + this.number.to_string()
					+ " on");
				bridge.put_light_state(
					this.number,
					"{\"on\":true,\"bri\":" + getBri().to_string() + ",\"sat\": "
						+ getSat().to_string() + ",\"hue\": " + getHue().to_string()
						+ "}"
				);
			}
			else {
				debug("[Light.toggleSwitch] switch " + this.number.to_string()
					+ " off");
				bridge.put_light_state(this.number, "{\"on\":false}");
			}
		}
		else {
			dont_change_switch = false;
		}
	}

	public void set_switch(bool active) {
		dont_change_switch = true;
		lightSwitch.active = active;
		debug("tried to switch this light");
	}

	public int get_light_id() {
		return this.number;
	}

	// callback from HueBridge after post_schedule()
	public void schedule_posted(Schedule s, string rsp) {
		// TODO  add Schedule to Lights below this Light
		// TODO  check wether rsp is "success", "error" or nothing
		// TODO  get schedule_id from Hue bridge

		has_more(true);
		lights.add_schedule_to_light(s, this.number);
	}

	private void update_css(double r, double g, double b) {
		int r255 = (int) (r * 255);
		int g255 = (int) (g * 255);
		int b255 = (int) (b * 255);
		debug("[Light.update_css] rgb = " + r255.to_string() + "," + g255.to_string() + ","
			+ b255.to_string());

		string css_data = "";
		if (lightSwitch.active) {
			css_data += ".switch" + this.number.to_string()
				+ ".trough { background-image:none; background-color: rgb("
				+ r255.to_string() + ", " + g255.to_string() + ", "
				+ b255.to_string() + "); } ";
		}
		else {
			// default Adwaita grey for switch that is off
			css_data += ".switch" + this.number.to_string()
				+ ".trough { background-image:none; background-color: #d3d7cf; } ";
		}
		css_data += ".scale" + this.number.to_string()
			+ ".trough.highlight { background-image:none; background-clip: content-box; background-color: rgb("
			+ r255.to_string() + ", " + g255.to_string() + ", "
			+ b255.to_string() + "); } ";
		try {
			css.load_from_data(css_data, css_data.length);
		}
		catch (Error e) {
			debug("[Light.update_css] error: " + e.message);
		}
		// this.show_all();
	}

	public void has_more(bool more) {
		if (more) {
			this.margin_bottom = 0;
		}
	}
}
