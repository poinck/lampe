// lampe-gtk by André Klausnitzer, CC0

using Soup;
using Posix;

public class HueBridge : Soup.Session {
	private string ip_address;
    private string user_name;
	public static const string BRIDGE_USER = "lampe-bash";
		// TODO  choose user name other than "lampe-bash", use "lampe"; the bash-version should then use the same user

	private const int DEFAULT_DELAY = 100; // 100 milliseconds
	private bool timer_is_running = false;
	private Soup.Message s_msg;

	public HueBridge(string ip_address, string user_name) {
		this.ip_address = ip_address;
        this.user_name = user_name;
	}

	// send message async without callback
	private void send_msg() {
		if (s_msg != null) {
			debug("[HueBridge.send_msg] request = '"
				+ (string) s_msg.request_body.flatten().data + "'");

			this.queue_message(s_msg, (s, m) => {
				debug("[HueBridge.send_msg] response = '"
					+ (string) m.response_body.flatten().data + "'");
			});
		}
	}

	// set state of a light
	public void put_light_state(int light, string request) {
		s_msg = new Soup.Message(
			"PUT",
			"http://" + this.ip_address + "/api/" + this.user_name
				+ "/lights/" + light.to_string() + "/state"
		);
		s_msg.set_request("application/json", MemoryUse.COPY, request.data);

		// delay msg and always send last msg in that delay-timeframe
		if (timer_is_running == false) {
			Timeout.add(DEFAULT_DELAY, () => {
				send_msg();
				timer_is_running = false;

				return false;
			});
			timer_is_running = true;
		}
	}

	// set state of a schedule
	public void put_schedule_state(Schedule schedule, string request) {
		Soup.Message msg = new Soup.Message(
			"PUT",
			"http://" + this.ip_address + "/api/" + this.user_name
				+ "/schedules/" + schedule.get_schedule_id().to_string()
		);
		msg.set_request("application/json", MemoryUse.COPY, request.data);

		this.queue_message(msg, (s, m) => {
			string rsp = (string) msg.response_body.flatten().data;
			debug("[HueBridge.put_schedule_state] response = '" + rsp + "'");

			// callback to where we came
			schedule.schedule_state_changed(rsp);
		});
	}

	// post a schedule
	public void post_schedule(Light light, Schedule schedule, string request) {
		Soup.Message msg = new Soup.Message(
			"POST",
			"http://" + this.ip_address + "/api/" + this.user_name
				+ "/schedules"
		);
		msg.set_request("application/json", MemoryUse.COPY, request.data);

		this.queue_message(msg, (s, m) => {
			string rsp = (string) msg.response_body.flatten().data;
			debug("[HueBridge.post_schedule] response = '" + rsp + "'");

			// callback to Lights
			light.schedule_posted(schedule, rsp);
		});
	}

	// set state of a group
	public void put_group_state(int group, string request) {
		s_msg = new Soup.Message(
			"PUT",
			"http://" + this.ip_address + "/api/" + this.user_name
				+ "/groups/" + group.to_string() + "/action"
		);
		s_msg.set_request("application/json", MemoryUse.COPY, request.data);

		// delay msg and always send last msg in that delay-timeframe
		if (timer_is_running == false) {
			Timeout.add(DEFAULT_DELAY, () => {
				send_msg();
				timer_is_running = false;

				return false;
			});
			timer_is_running = true;
		}
	}

	// get all states of all lights
	public void get_states(Lights lights) {
		Soup.Message msg = new Soup.Message(
			"GET",
			"http://" + this.ip_address + "/api/" + this.user_name + "/lights"
		);

		this.queue_message(msg, (s, m) => {
			string rsp = (string) msg.response_body.flatten().data;
			debug("[HueBridge.get_states] response = '" + rsp + "'");

			// callback to where we came
			lights.states_received(rsp);
		});
	}

	// get all schedules
	public void get_schedules(Lights lights) {
		Soup.Message msg = new Soup.Message(
			"GET",
			"http://" + this.ip_address + "/api/" + this.user_name + "/schedules"
		);

		this.queue_message(msg, (s, m) => {
			string rsp = (string) msg.response_body.flatten().data;
			debug("[HueBridge.get_schedules] response = '" + rsp + "'");

			// callback to where we came
			lights.schedules_received(rsp);
		});
	}

	// register at Hue bridge
	public void register(Gtk.Window window) {
		if (ip_address == "") {
			// the bridge needs to be found
				// TODO
			Gtk.MessageDialog dialog = new Gtk.MessageDialog(
				window,
				Gtk.DialogFlags.MODAL,
				Gtk.MessageType.WARNING,
				Gtk.ButtonsType.OK,
				"Not implemented yet. Please use 'lampe' in a Terminal to detected the Hue bridge in your network and register."
			);
			dialog.response.connect((response_id) => {
				switch (response_id) {
					case Gtk.ResponseType.OK:
						debug("Ok");
						break;
				}

				dialog.destroy();
			});
			dialog.show();
		}
		else {
			// bridge was already detected
			Gtk.MessageDialog dialog = new Gtk.MessageDialog(
				window,
				Gtk.DialogFlags.MODAL,
				Gtk.MessageType.WARNING,
				Gtk.ButtonsType.OK,
				"The Hue bridge was already detected at '" + ip_address + "'."
			);
			dialog.response.connect((response_id) => {
				switch (response_id) {
					case Gtk.ResponseType.OK:
						debug("Ok");
						break;
				}

				dialog.destroy();
			});
			dialog.show();
		}
	}
}
