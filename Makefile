OBJECTS = $(patsubst %.vhd, %.o, $(wildcard *.vhd))
GHDLFLAGS = --ieee=synopsys
# Program input. If not defined environment variable
# it will be defined as test_sisa
INPUT ?= test_sisa
# Stop simulation at stop_time. If not defined environment
# variable it will be defined as test_sisa
STOP_TIME ?= 12000ns

all: INPUT

INPUT: $(OBJECTS)
	ghdl -e $(GHDLFLAGS) $(INPUT)

%.o: %.vhd
	ghdl -a $(GHDLFLAGS) $^

simul: INPUT
	ghdl -r $(INPUT) --stop-time=$(STOP_TIME) --wave=$(INPUT).ghw

clean:
	rm -rf *.o
	rm -rf $(INPUT)
	rm -rf *.ghw
