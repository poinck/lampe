using Gtk;

public class Light : Box {

	// initialize a Box for a light
	public Light(string name) {
		this.spacing = 16;
		this.margin_top = 8;
		this.margin_bottom = 8;
		this.border_width = 1;
		this.valign = Align.END;
		
		Label lightName = new Label (name);
		lightName.valign = Align.BASELINE;
		this.pack_start (lightName, true, false, 8);
		Scale scaleSat = new Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleSat.draw_value = false;
		scaleSat.width_request = 254;
		scaleSat.valign = Align.END;
		this.pack_start (scaleSat, false, false, 0);
		Scale scaleBri = new Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleBri.draw_value = false;
		scaleBri.width_request = 254;
		scaleBri.valign = Align.END;
		this.pack_start (scaleBri, false, false, 0);
		Switch lightSwitch = new Switch();
		lightSwitch.valign = Align.END;
		
		this.pack_start (lightSwitch, false, false, 8);
	}
}
