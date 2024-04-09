# Generic Build script for CC65
#
# This file is responsible for compiling source code.
# It has some hooks for additional behaviour, see additional files it sources below.
# 
# The compilation will look in following directories for source:
# src/*.[c|s]               # considered the "top level" dir, you can keep everything in here if you like, will not recurse into subdirs
# src/common/**/*.[c|s]     # ie. common files for all platforms not in root dir - allows for splitting functionality out into subdirs
# src/<target>/**/*.[c|s]   # ie. including its subdirs - only CURRENT_TARGET files will be found
#
# This script sources the following files to add additional behaviour.
#  makefiles/os.mk                 # for platform mappings (e.g. atarixl -> atari, apple2enh -> apple), emulator base settings
#  makefiles/common.mk             # for things to be added for all platforms
#  makefiles/custom-<platform>.mk  # for platform specific values, LDFLAGS etc for current PLATFORM (e.g. atari)
#
# To add additional tasks to "all", in the sourced makefiles, add a value to "ALL_TASKS"
# For creating platform specific DISK images, add the disk creating task to "DISK_TASKS"
# Additional tasks in these makefiles MUST start with ".", e.g. ".po: ..."
# To add a suffix to the generated executable, ensure "SUFFIX" value is set.

# NOTE: All files referenced in this makefile are relative to the ORIGINAL Makefile in the root dir, not this dir

SHELL := /usr/bin/env bash
ALL_TASKS =
DISK_TASKS =

-include makefiles/os.mk

CC := cl65
CL := cl65

SRCDIR := src
BUILD_DIR := build
OBJDIR := obj
DIST_DIR := dist

# This allows src to be nested withing sub-directories.
rwildcard=$(wildcard $(1)$(2))$(foreach d,$(wildcard $1*), $(call rwildcard,$d/,$2))

PROGRAM_TGT := $(PROGRAM).$(CURRENT_TARGET)

SOURCES := $(wildcard $(SRCDIR)/*.c)
SOURCES += $(wildcard $(SRCDIR)/*.s)

# allow for a src/common/ dir and recursive subdirs
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.s)
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.c)

# allow src/<target>/ and its recursive subdirs
SOURCES_TG := $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/,*.c)

# remove trailing and leading spaces.
SOURCES := $(strip $(SOURCES))
SOURCES_TG := $(strip $(SOURCES_TG))

# convert from src/your/long/path/foo.[c|s] to obj/your/long/path/foo.o
OBJ1 := $(SOURCES:.c=.o)
OBJECTS := $(OBJ1:.s=.o)
OBJECTS := $(OBJECTS:$(SRCDIR)/%=$(OBJDIR)/%)

OBJ2 := $(SOURCES_TG:.c=.o)
OBJECTS_TG := $(OBJ2:.s=.o)
OBJECTS_TG := $(OBJECTS_TG:$(SRCDIR)/%=$(OBJDIR)/%)

OBJECTS += $(OBJECTS_TG)

ASFLAGS += --asm-include-dir src/common --asm-include-dir src/$(CURRENT_TARGET)
CFLAGS += --include-dir src/common --include-dir src/$(CURRENT_TARGET)

ASFLAGS += --asm-include-dir $(SRCDIR)
CFLAGS += --include-dir $(SRCDIR)

# allow for additional flags etc
-include ./makefiles/common.mk
-include ./makefiles/custom-$(CURRENT_PLATFORM).mk

STATEFILE := Makefile.options
-include $(STATEFILE)

define _listing_
  CFLAGS += --listing $$(@:.o=.lst)
  ASFLAGS += --listing $$(@:.o=.lst)
endef

define _mapfile_
  LDFLAGS += --mapfile $$@.map
endef

define _labelfile_
  LDFLAGS += -Ln $$@.lbl
endef

ifeq ($(origin _OPTIONS_),file)
OPTIONS = $(_OPTIONS_)
$(eval $(OBJECTS): $(STATEFILE))
endif

# Transform the abstract OPTIONS to the actual cc65 options.
$(foreach o,$(subst $(COMMA),$(SPACE),$(OPTIONS)),$(eval $(_$o_)))

# Sanity check
ifeq ($(BUILD_DIR),)
BUILD_DIR := build
endif

# Sanity check
ifeq ($(OBJDIR),)
OBJDIR := obj
endif

.SUFFIXES:
.PHONY: all clean release $(DISK_TASKS) $(BUILD_TASKS) $(PROGRAM).$(CURRENT_TARGET)

all: $(ALL_TASKS) $(PROGRAM_TGT)

$(OBJDIR):
	$(call MKDIR,$@)

$(BUILD_DIR):
	$(call MKDIR,$@)

$(DIST_DIR):
	$(call MKDIR,$@)

SRC_INC_DIRS := \
  $(sort $(dir $(wildcard $(SRCDIR)/$(CURRENT_TARGET)/*))) \
  $(sort $(dir $(wildcard $(SRCDIR)/common/*))) \
  $(SRCDIR)

vpath %.c $(SRC_INC_DIRS)

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_PLATFORM) -c --create-dep $(@:.o=.d) $(CFLAGS) -o $@ $<

vpath %.s $(SRC_INC_DIRS)

$(OBJDIR)/%.o: %.s | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_PLATFORM) -c --create-dep $(@:.o=.d) $(ASFLAGS) -o $@ $<


$(BUILD_DIR)/$(PROGRAM_TGT): $(OBJECTS) $(LIBS) | $(BUILD_DIR)
	$(CC) -t $(CURRENT_PLATFORM) $(LDFLAGS) -o $@ $^


$(PROGRAM_TGT): $(BUILD_DIR)/$(PROGRAM_TGT) | $(BUILD_DIR)

test: $(PROGRAM_TGT)
	$(PREEMUCMD)
	$(EMUCMD) $(BUILD_DIR)\\$<
	$(POSTEMUCMD)

clean:
	@for d in $(BUILD_DIR) $(OBJDIR) $(DIST_DIR); do \
      if [ -d "./$$d" ]; then \
	    echo "Removing $$d"; \
        rm -rf ./$$d; \
      fi; \
    done

release: all | $(BUILD_DIR) $(DIST_DIR)
	cp $(BUILD_DIR)/$(PROGRAM_TGT) $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)

disk: release $(DISK_TASKS)
