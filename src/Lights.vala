using Gtk;
using Json;

public class Lights : ListBox {
	public static const int MAX_LIGHTS = 50;

	private int light_count = 0;	
	private List<Box> lights;
	private HueBridge bridge;

	// initialize a ListBox for lights
	public Lights(HueBridge bridge) {
		this.hexpand = true;
		this.vexpand = false;
		this.margin_start = 1;
		this.margin_end = 1;
		this.margin_top = 1;
		this.margin_bottom = 1;
		this.activate_on_single_click = false;
		this.selection_mode = SelectionMode.NONE;
		this.border_width = 1;
		
		this.bridge = bridge;
	}
	
	// XXX   obsolete
	private Box packLight(int number, string name, int hue, int sat, int bri, bool lswitch) {
		Box box = new Box(Orientation.HORIZONTAL, 0);
		
		box.spacing = 16;
		box.margin_top = 8;
		box.margin_bottom = 8;
		box.border_width = 1;
		box.valign = Align.END;
		
		// number
		Label lightNumber = new Label("<b>" + number.to_string() + "</b>");
		lightNumber.use_markup = true;
		lightNumber.valign = Align.BASELINE;
		box.pack_start(lightNumber, false, false, 8);
		
		// hue
		Gtk.Button lightHue = new Gtk.Button.from_icon_name(
			"dialog-information-symbolic", 
			Gtk.IconSize.SMALL_TOOLBAR
		);
		box.pack_start(lightHue, false, false, 0);
		
		// debug
		stdout.printf("[Light] name '%s'\n", name);
		
		// name
		Label lightName = new Label(name);
		lightName.valign = Align.BASELINE;
		box.pack_start(lightName, false, false, 4);
		
		Label emptyLabel = new Label(" ");
		box.pack_start(emptyLabel, true, false, 0);
		
		// saturation
		Scale scaleSat = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleSat.set_value((double) sat);
		scaleSat.draw_value = false;
		scaleSat.width_request = 128;
		scaleSat.margin_bottom = 4;
		scaleSat.valign = Align.END;
		box.pack_start(scaleSat, false, false, 0);
		
		// brightness
		Scale scaleBri = new Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 254, 1);
		scaleBri.set_value((double) bri);
		scaleBri.draw_value = false;
		scaleBri.width_request = 254;
		scaleBri.margin_bottom = 4;
		scaleBri.valign = Align.END;
		box.pack_start(scaleBri, false, false, 0);
		
		// switch: on, off 
		Switch lightSwitch = new Switch();
		lightSwitch.active = lswitch;
		lightSwitch.margin_bottom = 4;
		lightSwitch.valign = Align.END;
		box.pack_start(lightSwitch, false, false, 8);
		lightSwitch.notify["active"].connect(() => {
			// TODO  toggleSwitch();
		});
		
		return box;
	}
	
	public void addLight(string name, int light_id = 1, int hue = 12000, int sat = 192, int bri = 32, bool lswitch = false) {
		this.light_count++;
		Light light = new Light(light_id, name, hue, sat, bri, lswitch, bridge);
		
		// debug
		stdout.printf("[Lights.addLight] light_count = '%i'\n", light_count);
		
		this.insert(light, light_count);
		this.show_all();
	}

//	private void insertBox(ref Box Box) {
//		this.lights.append(box);
//	}
	
//	public void addLight(string name, int light_id = 1, int hue = 12000, int sat = 192, int bri = 32, bool lswitch = false) {
//		this.light_count++;
//		Box box = packLight(light_id, name, hue, sat, bri, lswitch);
//		lights.append(box);
//		// insertBox(box);
//		
//		// debug
//		stdout.printf("[Lights.addLight] light_count = '%i'\n", light_count);
//		
//		this.insert(box, light_count);
//		this.show_all();
//	}
	
	public void deleteLights() {
//		List<Box> boxes = (List<Box>) this.get_children();
//		foreach (Box box in boxes) {
////			List<Widget> things = light.get_children();
////			foreach (Widget thing in things) {
////				thing.destroy();
////			}
//			// lights.remove_link(light);
//			
//			// light.get_parent().destroy();
//			
//			// debug
//			// stdout.printf("refcount = %i\n", (int) light.ref_count);
//			// light.dispose();
//			// light.unref();
//			
//			// stdout.printf("refcount(2) = %i\n", (int) light.ref_count);
//			
//			// lights.remove(light);
//			this.remove(box);
//			// lights.remove_all(box);
//			// light.deleteLight();
//		}		
		
		this.foreach((w) => {
			remove(w);
		});
		
		this.light_count = 0;
	}
	
	public void refreshLights() {
		deleteLights();
		
		string lightName = "";
		
		string lightStates = this.bridge.getStates();
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(lightStates);
			Json.Node node = parser.get_root();
			
			Json.Object lightObj = node.get_object();
			foreach (string light in lightObj.get_members()) {
				// debug
				stdout.printf("[Lights.refreshLights] light = '%s'\n", light);
				
				Json.Node categoryNode = lightObj.get_member(light);
				Json.Object categoryObj = categoryNode.get_object();
				foreach (string category in categoryObj.get_members()) {
					// debug
					stdout.printf("[Lights.refreshLights] category ?= '%s'\n", category);
				
					if (category == "state") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
//						Json.Node nameNode = categoryObj.get_member(category);
//						Json.Object stateObj = stateNode.get_object();
//						foreach (string category in stateObj.get_members()) {
					}
					else if (category == "name") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
						lightName = categoryObj.get_string_member(category);
						
						// degug
						stdout.printf("[Lights.refreshLights] lightName = '%s'\n", lightName);
					}
				}
				
				// degug
				stdout.printf("[Lights.refreshLights] lightName (addLight) = '%s'\n", lightName);
				
				// TODO  add light here
				// this.light_count++;
				addLight(lightName);
			}
			
//			for (int light = 1; light <= MAX_LIGHTS; light++) {
//				
//			}
		}
		catch (Error e) {
			stdout.printf("[Lights.refreshLights] unable to parse 'lightStates': %s\n", e.message);
		}
	}
}
