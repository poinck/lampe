using Gtk;

public class Light : Box {

	// initialize a Box for a light
	public Light(int number, string name, int hue, int sat, int bri, bool lswitch) {
		this.spacing = 16;
		this.margin_top = 8;
		this.margin_bottom = 8;
		this.border_width = 1;
		this.valign = Align.END;
		
		// number
		Label lightNumber = new Label("<b>" + number.to_string() + "</b>");
		lightNumber.use_markup = true;
		lightNumber.valign = Align.BASELINE;
		this.pack_start(lightNumber, false, false, 8);
		
		// hue
		Gtk.Button lightHue = new Gtk.Button.from_icon_name("dialog-information-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		this.pack_start(lightHue, false, false, 0);
		
		// name
		Label lightName = new Label(name);
		lightName.valign = Align.BASELINE;
		this.pack_start(lightName, false, false, 4);
		
		Label emptyLabel = new Label(" ");
		this.pack_start(emptyLabel, true, false, 0);
		
		// saturation
		Scale scaleSat = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleSat.set_value((double) sat);
		scaleSat.draw_value = false;
		scaleSat.width_request = 128;
		scaleSat.margin_bottom = 4;
		scaleSat.valign = Align.END;
		this.pack_start(scaleSat, false, false, 0);
		
		// brightness
		Scale scaleBri = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleBri.set_value((double) bri);
		scaleBri.draw_value = false;
		scaleBri.width_request = 254;
		scaleBri.margin_bottom = 4;
		scaleBri.valign = Align.END;
		this.pack_start(scaleBri, false, false, 0);
		
		// switch: on, off 
		Switch lightSwitch = new Switch();
		lightSwitch.active = lswitch;
		lightSwitch.margin_bottom = 4;
		lightSwitch.valign = Align.END;
		
		this.pack_start(lightSwitch, false, false, 8);
	}
}
