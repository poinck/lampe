// lampe-gtk by André Klausnitzer, CC0

public class Schedules {
	private List<Schedule> schedules;
	// private int light_id;

	public Schedules() {
		// this.light_id = light_id;
	}

	public void add_schedule(Schedule s) {
		schedules.append(s);
	}

	public Schedule get_schedule(int i) {
		return schedules.nth_data(i);

	}
}
