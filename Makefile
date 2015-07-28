# horst - Highly Optimized Radio Scanning Tool
#
# Copyright (C) 2005-2015 Bruno Randolf (br1@einfach.org)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# build options
DEBUG=1
PCAP=0

NAME=horst
OBJS=main.o capture$(if $(filter 1,$(PCAP)),-pcap).o protocol_parser.o \
	protocol_parser_wlan.o network.o wext.o node.o essid.o channel.o \
	util.o wlan_util.o ieee80211_util.o listsort.o average.o \
	display.o display-main.o display-filter.o display-help.o \
	display-statistics.o display-essid.o display-history.o \
	display-spectrum.o display-channel.o control.o \
	radiotap/radiotap.o conf_options.o ifctrl-nl80211.o
LIBS=-lncurses -lm -lnl-3 -lnl-genl-3
CFLAGS+=-Wall -Wextra -g -I. $(shell pkg-config --cflags libnl-3.0)

ifeq ($(DEBUG),1)
CFLAGS+=-DDO_DEBUG
endif

ifeq ($(PCAP),1)
CFLAGS+=-DPCAP
LIBS+=-lpcap
endif

.PHONY: all check clean force

all: $(NAME)

.objdeps.mk: $(OBJS:%.o=%.c)
	gcc -MM $^ >$@

-include .objdeps.mk

$(NAME): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

$(OBJS): .buildflags

check:
	sparse *.[ch]

clean:
	-rm -f *.o radiotap/*.o *~
	-rm -f $(NAME)
	-rm -f .buildflags

.buildflags: force
	echo '$(CFLAGS)' | cmp -s - $@ || echo '$(CFLAGS)' > $@
