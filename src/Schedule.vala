// lampe-gtk by André Klausnitzer, CC0

public class Schedule {
	private int light_id;
	private int schedule_id;
	private string time;
	private int64 bri = 192;
	private int64 sat = 254;
	
	public Schedule(int schedule_id, int light_id, string time, int64 bri = 192, int64 sat = 254) {
		this.schedule_id = schedule_id;
		this.light_id = light_id;
		this.time = time;
		this.bri = bri;
		this.sat = sat;
	}
	
	public int get_light_id() {
		return this.light_id;
	}
}
