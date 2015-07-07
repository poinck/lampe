// lampe-gtk by André Klausnitzer, CC0

using Gtk;
using Json;

public class Lights : ListBox {
	public static const int MAX_LIGHTS = 50;

	private int light_count = 0;	

	private HueBridge bridge;
	private Switch group_switch;

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
	
	// remove every Light or placeholder in Lights
	private void delete_lights() {
		this.foreach((light) => {
			remove(light);
		});
		
		this.light_count = 0;
	}
	
	// add "searching lights"-placeholder to ListBox with spinner and refresh
	public void refresh_lights() {
		delete_lights();
		
		Box box = new Box(Orientation.HORIZONTAL, 8);
		
		Label empty = new Label("");
		box.pack_start(empty, true, false, 0);
		
		Gtk.Spinner spinner = new Gtk.Spinner();
		spinner.active = true;
		spinner.opacity = 0.5;
		box.add(spinner);
	
		Label label = new Label("<span size='16000'><b>searching lights ...</b></span>");
		label.use_markup = true;
		label.margin = 12;
		Gdk.RGBA label_color = Gdk.RGBA();
		label_color.parse("#a4a4a4"); // grey
		label.override_color(StateFlags.NORMAL, label_color);
		box.add(label);
		
		Label empty2 = new Label("");
		box.pack_start(empty2, true, false, 0);
		
		this.add(box);
		this.show_all();
		
		this.bridge.get_states(this);
	}
	
	// callback from bridge.get_states(): parses received light states and adds 
	// lights as found or "no lights"-placeholder
	public void states_received(string states) {
		delete_lights();
	
		string name = "";
		int light_id = 0;
		int64 hue = 12000;
		int64 sat = 192;
		int64 bri = 32;
		bool lswitch = false;
		bool reachable = false;
	
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(states);
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
				"[Lights.refreshLights] unable to parse 'states': %s\n", 
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
	
	// creates a Box with captions and the global light switch with correct 
	// alignment to the ListBox
	public Box get_header() {
		Box box = new Box(Orientation.HORIZONTAL, 8);
		box.spacing = 16;
		
		Label placeholder_hue = new Label(" ");
		placeholder_hue.width_request = 24;
		box.pack_start(placeholder_hue, false, false, 8);
		
		Label placeholder_number_name = new Label("  ");
		box.pack_start(placeholder_number_name, true, false, 0);
		
		Label sat_label = new Label("<b>Saturation</b>");
		sat_label.use_markup = true;
		sat_label.width_request = 127;
		box.pack_start(sat_label, false, false, 0);
		
		Label bri_label = new Label("<b>Brightness</b>");
		bri_label.use_markup = true;
		bri_label.width_request = 127;
		box.pack_start(bri_label, false, false, 0);
		
		Label placeholder_swi = new Label(" ");
		placeholder_swi.width_request = 94;
		box.pack_start(placeholder_swi, false, false, 10);
		
		return box;
	}
	
	public Box get_global_switch() {
		Box box = new Box(Orientation.HORIZONTAL, 0);
	
		Label label = new Label("All lights");
		box.pack_start(label, false, false, 0);
		
		group_switch = new Switch();
		group_switch.tooltip_text = "all lights";
		group_switch.active = true;
		group_switch.margin_bottom = 4;
		group_switch.margin_end = 4;
		group_switch.valign = Align.END;
		group_switch.notify["active"].connect(() => {
			toggle_group_switch();
		});
		box.pack_start(group_switch, false, false, 8);
		
		return box;
	}
	
	public void toggle_group_switch() {
		if (group_switch.active) {
			debug("[Lights.toggle_group_switch] switch on");
			
			// "0" is special group, meaning all lights known to th Hue bridge
			bridge.put_group_state(0, "{\"on\":true}");
			
			/*
			List<Light> lights = (List<Light>) this.get_children();
			foreach(Light light in lights) {
				light.set_switch(true);
			}
			*/
				// FIXME find a way to toggle all individual light switches
			
			/*
			this.foreach((w) => {
				try {
					Light light = (Light) w.get_child();
					light.set_switch(true);
				}
				catch (Error e) {
					debug("header ignored");
				}
			});
			*/
		} 
		else {
			debug("[Lights.toggle_group_switch] switch off");
			bridge.put_group_state(0, "{\"on\":false}");
			
			/*
			List<Light> lights = (List<Light>) this.get_children();
			foreach(Light light in lights) {
				light.set_switch(false);
			}
			*/
			
			/*
			this.foreach((w) => {
				try {
					Light light = (Light) w.get_child();
					light.set_switch(false);
				}
				catch (Error e) {
					debug("header ignored");
				}
			});
			*/
		}
	}
	
	public int get_light_count() {
		return light_count;
	}
}
