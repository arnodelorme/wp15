# Apptainer executable (use 'singularity' if Apptainer is not installed)
APPTAINER = apptainer

# Directory containing definition files
DEF_DIR = .

# Find all definition files (.def) in the definition directory
DEF_FILES = $(wildcard $(DEF_DIR)/*.def)

# Generate corresponding container names (.sif) from definition files
CONTAINERS = $(DEF_FILES:.def=.sif)

# Default target: build all containers
all: $(CONTAINERS)

# Rule to build a .sif container from a .def file
%.sif: %.def
	$(APPTAINER) build $@ $<

# Clean up generated container files
clean:
	rm -f $(CONTAINERS)

# Phony targets (targets that are not files)
.PHONY: all clean
