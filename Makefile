OBJECTS = $(patsubst %.vhd, %.o, $(wildcard *.vhd))
GHDLFLAGS = --ieee=synopsys
# Program input. If not defined environment variable
# it will be defined as test_sisa
INPUT ?= test_sisa
# Stop simulation at stop_time. If not defined environment
# variable it will be defined as test_sisa
STOP_TIME ?= 12000ns

all:
	ghdl -m $(GHDLFLAGS) $(INPUT)

simul: all
	ghdl -r $(INPUT) --stop-time=$(STOP_TIME) --wave=$(INPUT).ghw

clean:
	ghdl --clean
