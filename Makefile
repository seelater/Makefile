# make BUILD=debug -j4
# make -j4
# make all -j4
# make clean
# make test -j4 

.PHONY: all clean test

ifeq ($(BUILD),debug)
  BUILD_DIR = debug
  CFLAGS += -g -O0
else
  BUILD_DIR = build
  CFLAGS += -O2 -DNDEBUG
endif

# if CC not set explicitly
ifeq ($(origin CC),default)
  CC = gcc
endif
override CFLAGS += -std=c2x -Wall -Wextra -pedantic $(INCS)\
		 #-D_POSIX_C_SOURCE=200809L

####################################################
#ROOT_DIR = $(shell pwd)
ROOT_DIR  = .
SRC_DIR   = $(ROOT_DIR)/source
BUILD_DIR ?= $(ROOT_DIR)/build
INC_DIR   = $(ROOT_DIR)/include
LIB_DIR   = $(ROOT_DIR)/lib
DEP_DIR   = $(OBJ_DIR)/deps
TEST_DIR  = $(ROOT_DIR)/test
####################################################
INCS  = -I$(INC_DIR)
LIBS  = -L$(LIB_DIR) #-lbox2d -lraylib -lm -lGL -ldl -lrt -lpthread -lX11
SRC  := $(shell find $(SRC_DIR) -name "*.c")
OBJ  := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC)) 
DEPS := $(OBJ:.o=.d)
#TESTFILES=$(wildcard $(TEST_DIR)/*.txt)
####################################################
BIN = name
####################################################
all: $(BIN)
	
#link
$(BIN): $(OBJ) 
	$(CC) -o $@ $^ $(LIBS) 

# create .o from .c
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $< 

# deps	
$(DEPS): $(BUILD_DIR)/%.d : $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) -E $(CFLAGS) $< -MM -MT $(@:.d=.o) > $@

clean:
	rm -rf $(BUILD_DIR) $(BIN) debug

# test: $(TESTFILES)	

####################################################
NODEPS := clean

ifneq ($(MAKECMDGOALS),NODEPS)
include $(DEPS)
endif
