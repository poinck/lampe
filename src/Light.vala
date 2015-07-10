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
	
	private Switch lightSwitch;
	private Scale scaleBri;
	private Scale scaleSat;
	// private Box schedule_box = new Box(Orientation.VERTICAL, 2);
	
	private List<Schedule> schedules = new List<Schedule>();

	// initialize a Box for a light
	public Light(int number, string name, int64 hue, int64 sat, int64 bri, 
			bool lswitch, bool reachable, HueBridge bridge) {
		this.spacing = 16;
		this.margin_top = 8;
		this.margin_bottom = 8;
		this.border_width = 1;
		this.valign = Align.END;
		
		this.number = number;
		this.bridge = bridge;
		
		// saturation
		scaleSat = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		
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
		// lightName.margin_top = 8;
		lightName.valign = Align.BASELINE;
		// schedule_box.add(lightName);
		this.pack_start(lightName, false, false, 4);
			
		Label emptyLabel = new Label(" ");
		this.pack_start(emptyLabel, true, false, 0);
		
		// switch: on, off
		lightSwitch = new Switch();
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
		scaleSat.override_background_color(StateFlags.NORMAL, color);
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
			scaleSat.override_background_color(StateFlags.NORMAL, color);
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
		this.pack_start(lightSwitch, false, false, 10);
		lightSwitch.notify["active"].connect(() => {
			toggle_switch();
		});
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
	
	public void add_schedule(Schedule schedule) {
		schedules.append(schedule);
		// schedule_box.add(schedule);
	}
}
