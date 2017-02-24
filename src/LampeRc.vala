// lampe-gtk by André Klausnitzer, CC0

public class LampeRc {
	public const string RC_FILE = "/.lamperc";

	private File rc_file;

    private string ip;
    private string user;

	public LampeRc() {
		rc_file = File.new_for_path(Environment.get_home_dir() + RC_FILE);
	}

    public string getIp() {
        return this.ip;
    }

    public string getUser() {
        return this.user;
    }

	public bool read() {
		if (rc_file.query_exists() == false) {
		    debug("[LampeRc] ERROR file '" + rc_file.get_path()
		    	+ "' does not exist.");
		    return false;
		}

		this.ip = "";
        this.user = "";

		try {
			DataInputStream dis = new DataInputStream(rc_file.read());
			string line;
			string[] parts_of_line;
			while ((line = dis.read_line(null)) != null) {
				if (line.contains("bridgeip=") == true) {
					debug("[LampeRc] found bridgeip");
					parts_of_line = line.split("\"");
#if DEBUG
					foreach (string part_of_line in parts_of_line) {
						debug("'" + part_of_line + "'");
					}
#endif
					if (parts_of_line.length >= 2) {
						this.ip = parts_of_line[1];
					}
				}

				if (line.contains("bridgeuser=") == true) {
					debug("[LampeRc] found bridgeuser");
					parts_of_line = line.split("\"");
#if DEBUG
					foreach (string part_of_line in parts_of_line) {
						debug("'" + part_of_line + "'");
					}
#endif
					if (parts_of_line.length >= 2) {
						this.user = parts_of_line[1];
					}
				}
			}
		}
		catch (Error e) {
			debug("[LampeRc] ERROR: " + e.message);
		}

		return true;
	}
}
