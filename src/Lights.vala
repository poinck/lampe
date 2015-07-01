using Gtk;
using Json;

public class Lights : ListBox {
	public static const int MAX_LIGHTS = 50;

	private int light_count = 0;	

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
	
	public void addLight(string name, int light_id = 1, int64 hue = 12000, 
			int64 sat = 192, int64 bri = 32, bool lswitch = false, 
			bool reachable = false) {
		this.light_count++;
		Light light = new Light(light_id, name, hue, sat, bri, lswitch, reachable, bridge);
		
		debug("[Lights.addLight] light_count = " + light_count.to_string());
		
		this.insert(light, light_count);
		this.show_all();
	}
	
	public void deleteLights() {
		// callback: remove() for every child of this (Lights)
		this.foreach((light) => {
			remove(light);
		});
		
		this.light_count = 0;
	}
	
	public void refreshLights() {
		deleteLights();
		
		string name = "";
		int light_id = 0;
		int64 hue = 12000;
		int64 sat = 192;
		int64 bri = 32;
		bool lswitch = false;
		bool reachable = false;
		
		string lightStates = this.bridge.getStates();
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(lightStates);
			Json.Node node = parser.get_root();
			
			Json.Object lightObj = node.get_object();
			foreach (string light in lightObj.get_members()) {
				debug("[Lights.refreshLights] light = " + light.to_string());
				
				light_id = int.parse(light);
				
				Json.Node categoryNode = lightObj.get_member(light);
				Json.Object categoryObj = categoryNode.get_object();
				foreach (string category in categoryObj.get_members()) {
					debug("[Lights.refreshLights] category ?= '" + category + "'");
				
					if (category == "state") {
						Json.Node stateNode = categoryObj.get_member(category);
						Json.Object stateObj = stateNode.get_object();
						foreach (string state in stateObj.get_members()) {
							if (state == "on") {
								lswitch = stateObj.get_boolean_member(state);
							}
							else if (state == "bri") {
								bri = stateObj.get_int_member(state);
							} 
							else if (state == "hue") {
								hue = stateObj.get_int_member(state);
								debug("[Lights.refreshLights] hue = " 
									+ hue.to_string()
								);
							} 
							else if (state == "sat") {
								sat = stateObj.get_int_member(state);
								debug("[Lights.refreshLights] sat = " 
									+ sat.to_string()
								);
							}
							else if (state == "reachable") {
								reachable = stateObj.get_boolean_member(state);
								debug("[Lights.refreshLights] reachable = " 
									+ reachable.to_string()
								);
							}
						}
					}
					else if (category == "name") {
						name = categoryObj.get_string_member(category);
						debug("[Lights.refreshLights] name = '" + name + "'");
					}
				}
				
				addLight(name, light_id, hue, sat, bri, lswitch, reachable);
			}
		}
		catch (Error e) {
			stdout.printf(
				"[Lights.refreshLights] unable to parse 'lightStates': %s\n", 
				e.message
			);
		}
		
		// show placeholder if no lights could be found
		if (light_count == 0) {
			Label label = new Label("<span size='16000'><b>no lights</b></span>");
			label.use_markup = true;
			label.margin = 12;
			Gdk.RGBA label_color = Gdk.RGBA();
			label_color.parse("#a4a4a4"); // grey
			label.override_color(StateFlags.NORMAL, label_color);
			
			this.add(label);
			this.show_all();
		}
	}
	
	public int get_light_count() {
		return light_count;
	}
}
