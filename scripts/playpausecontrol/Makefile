BIN=playpausecontrol
BINDIR=/usr/bin
SYSTEMDDIR=/etc/systemd/system

install:
	-sudo systemctl stop $(BIN).service
	-sudo cp $(BIN).sh $(BINDIR)/$(BIN)
	-sudo cp $(BIN).service $(SYSTEMDDIR)/$(BIN).service
	-sudo systemctl enable $(BIN).service
	-sudo systemctl start $(BIN).service

uninstall:
	-sudo systemctl stop $(BIN).service
	-sudo systemctl disable $(BIN).service
	-sudo rm $(SYSTEMDDIR)/$(BIN).service
	-sudo rm $(BINDIR)/$(BIN)
