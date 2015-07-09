// lampe-gtk by André Klausnitzer, CC0

using Gtk;
using Json;

public class Lights : ListBox {
	public static const int MAX_LIGHTS = 50;

	private int light_count = 0;
	private bool all_lights_are_on = true; 
		// "all_lights_are_on": false assumption to determine initial light 
		// switch position of global switch
	private bool refreshed = false;

	private HueBridge bridge;
	private Switch group_switch;
	private List<Light> lights = new List<Light>();

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
	
	// depricated
	public void addLight(string name, int light_id = 1, int64 hue = 12000, 
			int64 sat = 192, int64 bri = 32, bool lswitch = false, 
			bool reachable = false) {
		this.light_count++;
		Light light = new Light(light_id, name, hue, sat, bri, lswitch, reachable, bridge);
		
		debug("[Lights.addLight] light_count = " + light_count.to_string());
		
		this.insert(light, light_count);
		this.show_all();
	}
	
	public void add_light(Light light) {
		this.light_count++;
		debug("[Lights.addLight] light_count = " + light_count.to_string());
		this.insert(light, light_count);
		this.show_all();
	}
	
	// remove every Light or placeholder in Lights
	private void delete_lights() {
		this.foreach((light) => {
			remove(light);
		});
		
		lights = new List<Light>();
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
								if (lswitch == false) {
									all_lights_are_on = false;
								}
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
				
				// addLight(name, light_id, hue, sat, bri, lswitch, reachable);
					// TODO  add lights after schedules are received, define Schedules-object as parameter
				Light found_light = new Light(
					light_id, name, hue, sat, bri, lswitch, reachable, bridge
				);
				lights.append(found_light);
			}
		}
		catch (Error e) {
			debug("[Lights.states_received] unable to parse 'states': "
				+ e.message);
		}
		
		debug("[Lights.states_received()] all_lights_are_on = " 
			+ all_lights_are_on.to_string());
		refreshed = true;
		if (all_lights_are_on) {
			group_switch.active = true;
		}
		else {
			group_switch.active = false;
		}
		
		// TODO  refresh schedules
		this.bridge.get_schedules(this);
	}
	
	// callback from bridge.get_schedules(): parses received schedules
	public void schedules_received(string schedules) {
		List<Schedule> schedule_list = new List<Schedule>();
	
		int schedule_id = 0;
		int light_id = 0;
		string name = "Alarm";
		int64 bri = 192;
		int64 sat = 254;
		string localtime = "W127/T";
		string time = "";
		string address = "/api/" + HueBridge.BRIDGE_USER + "/lights/";
		string[] parts_of_address;
		
		Json.Parser parser = new Json.Parser();
		try {
			/*
			{"1":{"name":"Alarm","description":"",
				"command":{
					"address":"/api/lampe-bash/lights/3/state",
					"body":{"on":true,"bri":192,"sat":254,"transitiontime":12000},
					"method":"PUT"
				},
				"localtime":"W127/T09:10:00",
				"time":"W127/T07:10:00",
				"created":"2015-07-09T19:34:48",
				"status":"enabled"
				},
			"2":{"name":"Alarm 1","description":"","command":{"address":"/api/lampe-bash/lights/1/state","body":{"on":true,"bri":192,"sat":254,"transitiontime":12000},"method":"PUT"},"localtime":"W127/T21:37:00","time":"W127/T19:37:00","created":"2015-07-09T19:35:25","status":"enabled"}}
			*/
			parser.load_from_data(schedules);
			Json.Node node = parser.get_root();
			
			Json.Object schedule_obj = node.get_object();
			foreach (string schedule in schedule_obj.get_members()) {
				schedule_id = int.parse(schedule);
				
				Json.Node category_node = schedule_obj.get_member(schedule);
				Json.Object category_obj = category_node.get_object();
				foreach (string category in category_obj.get_members()) {
					if (category == "name") {
						name = category_obj.get_string_member(category);
						debug("[Lights.schedules_received] name = '" + name 
							+ "'");
					}
					else if (category == "command") {
						Json.Node command_node = category_obj.get_member(category);
						Json.Object command_obj = command_node.get_object();
						foreach (string command in command_obj.get_members()) {
							if (command == "address") {
								address = command_obj.get_string_member(command);
								debug("[Lights.schedules_received] address = '" 
									+ address + "'");
								parts_of_address = address.split("/");
								if (parts_of_address[3] == "lights") {
									light_id = int.parse(parts_of_address[4]);
								}
								debug("[Lights.schedules_received] light_id = '" 
									+ light_id.to_string() + "'");
							}
							else if (command == "body") {
								// TODO  parse bri and sat
							}
						}
					}
					else if (category == "localtime") {
						localtime = category_obj.get_string_member(category);
						debug("[Lights.schedules_received] localtime = '" 
							+ localtime + "'");
						time = localtime.split("/T")[1];
						time = time.split(":00")[0];
					}
				}
				
				// insert found schedules
				Schedule s = new Schedule(schedule_id, light_id, time, bri, sat);
				schedule_list.append(s);
			}
		}
		catch (Error e) {
			debug("[Lights.schedules_received] unable to parse 'schedules': " 
				+ e.message);
		}
		
		// TODO  add schedules to lights
		foreach (Light light in lights) {
			List<Schedule> light_schedules = new List<Schedule>();
			foreach (Schedule a_schedule in schedule_list) {
				if (light.get_light_id() == a_schedule.get_light_id()) {
					// light_schedules.append(a_schedule);
					light.add_schedule(a_schedule);
				}
			}
			// light.add_schedules(light_schedules);
			add_light(light);
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
	
	// creates a Box with captions with correct alignment to the ListBox
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
	
	// initalizes global switch. do not call this method before first call of
	// refresh_lights()
	public Box get_global_switch() {
		Box box = new Box(Orientation.HORIZONTAL, 0);
	
		Label label = new Label("All lights");
		box.pack_start(label, false, false, 0);
		
		group_switch = new Switch();
		// group_switch.tooltip_text = "all lights";
		
		group_switch.margin_bottom = 4;
		group_switch.margin_end = 4;
		group_switch.valign = Align.END;
		group_switch.notify["active"].connect(() => {
			if (refreshed == false) {
				toggle_group_switch();
			}
			else {
				refreshed = false;
			}
				
		});
		box.pack_start(group_switch, false, false, 8);
		
		return box;
	}
	
	public void toggle_group_switch() {
		if (group_switch.active) {
			debug("[Lights.toggle_group_switch] switch on");
			
			// "0" is special group, meaning all lights known to th Hue bridge
			bridge.put_group_state(0, "{\"on\":true}");
			
			// change light switch state of individual lights
			this.foreach((w) => {
				try {
					ListBoxRow r = (ListBoxRow) w;
					Light light = (Light) r.get_child();
					light.set_switch(true);
				}
				catch (Error e) {
					debug("header ignored");
				}
			});
		} 
		else {
			debug("[Lights.toggle_group_switch] switch off");
			bridge.put_group_state(0, "{\"on\":false}");
			
			this.foreach((w) => {
				try {
					ListBoxRow r = (ListBoxRow) w;
					Light light = (Light) r.get_child();
					light.set_switch(false);
				}
				catch (Error e) {
					debug("header ignored");
				}
			});
		}
	}
	
	public int get_light_count() {
		return light_count;
	}
}
